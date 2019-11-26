require "gtk"

Gtk::TextBuffer
class Console < Gtk::Window
  class << self; attr_accessor :default; end
  
  attr_reader :out,:cmd
  
  def initialize
    super :toplevel
   
    self.title = "RXPP::Console #{RXPP::Plugin.default.display_name}"
   
    self.class.default = self
   
    @out  = Gtk::TextView.new
    @cmd  = Gtk::Entry.new
   
    @out.buffer.text = "# #{__FILE__}"
   
    @cmd.signal_connect "activate" do
      append ">> "+cmd.text
    
      begin
        append ::Object.send(:eval,cmd.text).inspect
      rescue => e
        begin
          RXPP::Plugin.default.log_error e
        rescue
          begin
            print_err e
          rescue
            STDERR.puts e
          end
        end 
      end
    end

    box = Gtk::Box.new :vertical,0
    
    add box
    
    box.pack_start @out, true, true, 2
    box.pack_start @cmd, false,false,2

    resize 500,500
    
    #show_all
    
    signal_connect "delete-event" do hide end
    hide
  end
  
  def append s
    end_iter = out.buffer.end_iter()
    out.buffer.insert(end_iter, s="\n"+s, s.length)
  end
end

if __FILE__ == $0
Gtk.init
Console.new
Gtk.main
end
