require 'gobject-introspection'
require 'cairo-gobject'
require 'gdk3/event-readers'
require 'gdk3/loader'
require 'gtk3/loader'

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

module Gtk; 
  def self.main_quit; Xfce4Panel::RubyPlugin.quit; end

  @l=Loader.new(self,[])
  
  class << @l;attr_reader :base_module;end
  
  GObjectIntrospection::Repository.default.require("Gtk","3.0")
  
  def self.const_missing c
    info = GObjectIntrospection::Repository.default.find("Gtk","#{c}")
    
    super if !info
    
    @l.send :load_info, info
    
    return Gtk.const_get(c)
  rescue => e
    print_err e
    Gtk.main_quit
  end  
        
        ### load some common base classes ###
        Widget;Container;Bin;Misc
        Button;ToggleButton;Image;
        Dialog;MenuItem;MenuShell
      end
