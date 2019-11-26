$: << File.expand_path(File.dirname(__FILE__))

module Gdk; 
  @l=Loader.new(self)
  
  class << @l;attr_reader :base_module; end
  
  def Loader.const_missing c
    Gdk.const_missing c
  end
  
  GObjectIntrospection::Repository.default.require("Gdk","3.0")
  
  def self.const_missing c
    info = GObjectIntrospection::Repository.default.find("Gdk","#{c}")
  
    @l.send :load_info, info
    
    Gdk.const_get(c)
  rescue => e
    print_err e
    Gtk.main_quit
  end 

  @l.send :convert_event_classes 
end;
