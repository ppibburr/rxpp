require 'gobject-introspection'
require 'cairo-gobject'
require 'gdk3/event-readers'
require 'gdk3/loader'
require 'gtk3/loader'
require 'gio2'

$: << File.expand_path(File.dirname(__FILE__))

require 'fast-gdk'

module Gtk;
  @l=Loader.new(self,[])
  
  class << @l;attr_reader :base_module;end
  
  r=GObjectIntrospection::Repository.default
  r.require("Gtk","3.0")
  
  [:main, :main_quit].each do |q|
    i = r.find("Gtk",q.to_s)
    @l.send :load_info, i
  end

  def self.init
    class << self
      remove_method :init
    end
    init_check = GObjectIntrospection::Repository.default.find("Gtk", "init_check")
    arguments = [
      [$0] + ARGV,
    ]
    succeeded, argv = init_check.invoke(arguments)
    ARGV.replace(argv[1..-1])
    succeeded
  end
  
  def self.method_missing m,*o,&b
    init if respond_to? :init
    @l.send :load_function_info, GObjectIntrospection::Repository.default.find("Gtk", "gtk_#{m}")
    super unless respond_to?(m)
    send m,*o,&b
  end
  
  def self.const_missing c
    init if respond_to? :init
    info = GObjectIntrospection::Repository.default.find("Gtk","#{c}")
    if info.respond_to?(:parent)
      if info.parent.namespace == "Gtk"
        const_missing info.parent.name.to_sym
      end
    end
    super if !info
    
    @l.send :load_info, info
    
    return Gtk.const_get(c)
  rescue => e
    begin
      print_err e
    rescue
      puts e
      puts e.backtrace.join("\n")
      Gtk.main_quit
    end
    Gtk.main_quit
  end       
end

module GLib
  GLib::VariantType::INT = GLib::VariantType::INT32

  l          = GObjectIntrospection::Loader.new(self)
  repository = GObjectIntrospection::Repository.default

  repository.require("GLib", "2.0")

  l.send :load_info,repository.find("GLib", "VariantDict")
  l.send :load_info,repository.find("GLib", "OptionFlags")
  l.send :load_info,repository.find("GLib", "OptionArg")  

  self::Object
  class self::Object
    class Lib
      extend FFI::Library
      ffi_lib "gobject-2.0"
      attach_function :g_object_ref, [:pointer],:void
    end
    def c_pointer
      addr = GLib::Object.instance_method(:inspect).bind(self).call().scan(/ptr\=(.*)\>/)[0][0].to_i(16)
    end
    
    def ffi_pointer
      FFI::Pointer.new(c_pointer())
    end
    
    def self.manage_ptr ptr
      GObjectIntrospection::Loader.instantiate_gobject_pointer(ptr.address)
    end    
    
    def ref
      Lib.g_object_ref(ffi_pointer)
    end
  end
end
  
module Gio
  l          = GObjectIntrospection::Loader.new(self)
  repository = GObjectIntrospection::Repository.default

  repository.require("Gio", "2.0")

  l.send :load_info,repository.find("Gio", "File")
  
  ApplicationCommandLine  
  
  class Gio::ApplicationCommandLine
    module Lib 
      extend FFI::Library
      ffi_lib "gio-2.0"
      attach_function :g_application_command_line_print,[:pointer,:string],:void
      attach_function :g_application_command_line_printerr,[:pointer,:string],:void      
    end
    
    # FIXME: does not get captured in `` 
    # @return IO invoking proccess stdin and stdout
    def io
      @io ||= IO.new(@fd=stdin.fd)    
    end
    
    # Print to invoking proccess stdout
    def print *s
      s.each do |_|
        Lib.g_application_command_line_print self.ffi_pointer, _.to_s+"\n"
      end
    end
    
    # Print to invoking proccess stderr
    def printerr *s
      s.each do |_|
        Lib.g_application_command_line_printerr self.ffi_pointer, _.to_s+"\n"
      end
    end    
  end

  Application
  class Application
    class Options
      attr_reader :application
      def initialize application
        @application = application
        @map         = {}
      end
      
      # Add main option entry to application
      #
      # @param String +long+  the option name
      # @param String +short+ the option short-name
      # @param String +desc+ the option description
      # @param Symbol|NilClass +type+ the type of argument for option
      def on long,short,desc,type=nil, &b
        t = gt = (type || :none)
        ((gt = "#{t[0]}_array") && t=t[0]) if type.is_a?(::Array)
        gt = :"#{gt.upcase}"
        
        @map[long] = {block: b, type: gt}

        application.add_main_option(long,short,GLib::OptionFlags::NONE,GLib::OptionArg.const_get(gt), desc, type ? t.to_s.upcase : nil) 
      end
    
      def parse dict
        opts= {}
        
        @map.each_pair do |k,v|
          v=opts[k]=dict.lookup_value(k, GLib::VariantType.const_get(@map[k][:type]))
          @map[k][:block].call v if @map[k][:block]
        end
        
        opts
      end
    end

    # Simplified Option Management
    # @return Options
    def options
      @options ||= Application::Options.new(self)
    end 

    # Overide to handle options locally
    #
    # @param Hash +opts+ The options and values passed
    #
    # @return Integer (-1 to continue, 0 or greater to exit, Default: -1)
    def local_options opts
      -1
    end
    
    # Override to handle options on the primary instance
    # calls GLib::Object#unref on +cmdline+ when done
    #
    # @param Hash +opts+ The options and values passed
    # @param Gio::ApplicationCommandLine +cmdline+
    #
    # @return Integer (Default: 0 The exit status for +cmdline+)
    def remote_options opts, cmdline, unref_cmdline=true
      args = cmdline.arguments[1..-1].map do |a|
        cmdline.create_file_for_arg(a).uri
      end
      
      args.empty? ? activate : open_files(args)
      
      unref_cmdline ? cmdline.unref : nil
      
      -1
    end
    
    # Override to implement file opening from ARGV after options are parsed out
    def open_files *o
      activate
    end
    
    class << self
      def new *o,&b
        ins = super
        ins.instance_exec do
          signal_connect "handle-local-options" do |_,dict|
            local_options(options.parse(dict))
          end
      
          signal_connect "command-line" do |_,c|
            result = remote_options options.parse(c.options_dict), c
            1
          end
        end
        ins
      end
    end
  end
end

if __FILE__ == $0
OPTIONS = [
  ["needs-value", "n", "Needs a value", [:string]],
  ["version",     "v", "print version"],
]

class Application < Gtk::Application
  def initialize
    super "org.ppibburr.test", Gio::ApplicationFlags::HANDLES_COMMAND_LINE|Gio::ApplicationFlags::HANDLES_OPEN

    OPTIONS.each do |o| options.on *o end
    options.on("add", "a", "adds to", :INT)
    
    signal_connect "activate" do |application|
      if !application.windows.first
        w=Gtk::ApplicationWindow.new(application)
      end
    end
  end
  
  def open_files files
    files.each { |file| p file}
  end
  
  def remote_options opts, cmdline
    cmdline.io.puts "Hello Local Instance. <From Remote>"
    cmdline.io.print ">>"
    cmdline.io.puts cmdline.io.gets
    
    super
  end
end
Application.new.run([$0]+ARGV)
end


if __FILE__ == $0
  Gtk.init
  w=Gtk::Window.new :toplevel
  w.show
  GLib::Timeout.add 600 do; Gtk.main_quit; end
  Gtk.main
end
