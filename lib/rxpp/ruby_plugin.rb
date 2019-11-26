require 'fileutils'
require 'ffi'
require 'gobject-introspection'
require 'json'  

$: << File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(File.dirname(__FILE__))+"/../"

require "rxpp"

require "xfce4-panel-plugin"

PLUGIN_DATA = JSON.parse(ARGV[0] || "{}")

$RXPP_LOG = lf="#{ENV["HOME"]}/.logs/xfce4/ruby-plugin/loader.rb.txt"
FileUtils.mkdir_p(File.dirname(lf))
File.open(lf,"w").close

def puts *o
  File.open($RXPP_LOG,"a") do |f| f.puts *o end
end

def print_err e
  puts e.backtrace.reverse.join("\n")
  puts e
end

puts "#{Time.now} Loading plugin library..."
  
module FFI
  def self.gi(ptr)
    GObjectIntrospection::Loader.instantiate_gobject_pointer(ptr.address)
  end
end

class ::Object
  def self.const_missing c
  
  if c == :libxfce4util
    return Xfce4Util
  end
  
  super
  end
end;
begin
module RXPP
  module Plugin
    class << self
      attr_reader :ini, :desktop_file
    end
    
    extend FFI::Library; 

    ffi_lib '/usr/lib/x86_64-linux-gnu/xfce4/panel/plugins/librubyplugin.so';

    attach_function :ruby_plugin_default, [],:pointer
    attach_function :gtk_container_add, [:pointer,:pointer], :void
    attach_function :gtk_widget_show, [:pointer], :void
    attach_function :xfce_panel_image_new_from_source, [:string], :pointer
    attach_function :xfce_panel_plugin_get_display_name,[:pointer],:string
    attach_function :xfce_panel_plugin_get_unique_id,[:pointer],:int    
    attach_function :gtk_main_quit,[],:void

    def self.quit; gtk_main_quit; end
    
    plug = ruby_plugin_default
    puts plugin: {name: name = xfce_panel_plugin_get_display_name(plug), id: xfce_panel_plugin_get_unique_id(plug)}

    @desktop_file = `grep "Name=#{name}" /usr/share/xfce4/panel/plugins/*.desktop`.split(":")[0]
    @ini = {}

    a = File.open(desktop_file, "r").read.scan(/(.*)\=(.*?)\n/)
    a.each do |k,v| ini[k]=v end

    img = xfce_panel_image_new_from_source(ini["Icon"])
    
    gtk_widget_show(img)
    gtk_container_add(plug, img) 
        
    module Base
      attr_reader :desktop_file, :ini
      
      def popup &b
        signal_connect("button-press-event") do |w,e,_|
          if e.button == 3
            next !!b.call
          end
          
          next false
        end if b
      end
      
      def clicked &b
        signal_connect("button-press-event") do |w,e,_|
          if e.button == 1
            next !!b.call()
          
            next true
          end
          false
        end if b
      end

      def about o={}
        signal_connect("about") do
          d=Gtk::AboutDialog.new

		      o.each_pair do |k,v|
		        d.send :"#{k}=", v
		      end

	        d.run
	        d.destroy
	      end
      end
      
      def run &initblk
        instance_exec &initblk
      rescue => e;
        log_error e
      end
      
      def event e=nil, v=nil,&b
        if b
          @_r = b; return
        end
        
        @_r.call(e) if @_r
      end
      
      def id; property_base.split("-")[-1].to_i; end
      
      def rc
        @rc||=Xfce4Util::Rc.simple_open(save_location(true),false)
      rescue => e
        print_err e
      end
      
      ## [], []= of an JSON configuration object persisted in plugins .rc file
      ## file is deleted when plugin removed from panel
      # Retrieve coniguration entry +k+ of this plugin instance
      def [] k
        JSON.parse(rc.read_entry("JSON","{}"), symbolize_names: true)[k]
      rescue => e
        print_err e
      end
      
      # Set configuration entry +k+ of this plugin instance
      def []= k,v
        s=rc.read_entry("JSON","{}")
        
        h=JSON.parse(s, symbolize_names: true)
        h[k]=v
        
        rc.write_entry("JSON", h.to_json)
        rc.flush
        
        v
      rescue => e
        print_err e
      end

      def log *o
        o.each do |_|
          begin;::Console.default.append "I, [#{Time.now}]  INFO : "+_.to_s;rescue;end
          (@logger ||= Logger.new(logfile)).info _
        end
        nil
      rescue => e
        print_err e
      end
      
      def base_dir
        bd=RXPP::PLUGIN_LOG_DIR
        FileUtils.mkdir_p bd
        bd
      end
      
      def logfile= f
        @logfile = f
      end
      
      def logfile
        @logfile ||= base_dir+"/#{display_name}/#{id}.log"
      end
      
      def log_error e
        begin
          ::Console.default.append s="E, [#{Time.now}] Error -- : \n"+e.backtrace.reverse.join("\n")+"\n"+e.to_s
        rescue; end
        logger.error e
      end
      
      def notify summary, body: nil, action: nil, &b
        n=Notify::Notification.new summary,body,ini["Icon"]
        n.add_action action[:name],action[:label], &b if action
        n
      rescue => e
        log_error e
      end
    end
    
    def self.default
      return @plugin if @plugin

      @plugin = GObjectIntrospection::Loader.instantiate_gobject_pointer(ruby_plugin_default.address)
      @plugin.extend Base
      
      Notify.init @plugin.display_name
      @plugin.logfile
      
      @plugin.log "Plugin initialize..."
      
      @plugin.signal_connect("destroy") do 
        `/usr/bin/env ruby #{ENV["HOME"]}/.local/bin/rxpp.rb -g -- -u "#{@plugin.display_name}"`
        Gtk.main_quit()   
      end
     
      `/usr/bin/env ruby #{ENV["HOME"]}/.local/bin/rxpp.rb -g -- -l "#{@plugin.display_name}"`
     
      @plugin.signal_connect "remote-event" do |_,s,v|
        begin
          if (s == "unload") and (!v or v.to_s == "#{@plugin.id}")
            begin;File.delete(@plugin.logfile);rescue;end
            @plugin.remove
            Gtk.main_quit
            false
          elsif (s=="show-console" or s=="log-window") and (!v or v.to_s == "#{@plugin.id}")
            ::Console.default.show_all
          elsif s == "restart"
            exit
          else
            @plugin.event(s,v)
            false
          end
        rescue => e
          @plugin.log_error e
        end
      end

      return @plugin
    rescue => e
      print_err e
    end
  end
end  

def plugin &clsblk
  plugin = RXPP::Plugin.default
  
  begin
    class << plugin; self; end.class_eval &clsblk
  rescue => e
    plugin.log_error e
  end
  
  plugin 
rescue => e
  print_err e
end

Thread.new do
  begin
    require 'gtk'
    require 'notify'
    
    require "#{File.dirname(__FILE__)}/console"      
      
    $rxpp = true
    
    GLib::Idle.add do
      next true if !$rxpp

      Xfce4Panel::Loader.new(Xfce4Panel,[]).load

      plug = RXPP::Plugin.default
            
      plug.instance_variable_set("@desktop_file",  RXPP::Plugin.desktop_file)
      plug.instance_variable_set("@ini",  RXPP::Plugin.ini)

      plug.children[0].destroy()
      
      Console.new      
      
      puts "Loading plugin: #{plug.ini["X-RUBY-File"]}..."
      begin
        require plug.ini["X-RUBY-File"]
      rescue => e
        plug.log_error e
        plug.logger.close
        Gtk.main_quit
      end
      
      puts "Plugin loaded."

      false
    end
  rescue => e
    print_err e
    Gtk.main_quit   
  end
end



rescue => e; print_err e; end

