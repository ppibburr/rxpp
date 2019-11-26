#!/usr/bin/env ruby

$: << File.expand_path(File.join(File.dirname(__FILE__),".."))

require 'rxpp'
require "rxpp/utils"
require 'rxpp/window'

MENU_XML=<<EOC
<?xml version="1.0" encoding="UTF-8"?>
<interface>
  <menu id="app-menu">
    <section>
      <attribute name="label" translatable="yes">Change label</attribute>
      <item>
        <attribute name="action">win.change_label</attribute>
        <attribute name="target">String 1</attribute>
        <attribute name="label" translatable="yes">String 1</attribute>
      </item>
      <item>
        <attribute name="action">win.change_label</attribute>
        <attribute name="target">String 2</attribute>
        <attribute name="label" translatable="yes">String 2</attribute>
      </item>
      <item>
        <attribute name="action">win.change_label</attribute>
        <attribute name="target">String 3</attribute>
        <attribute name="label" translatable="yes">String 3</attribute>
      </item>
    </section>
    <section>
      <item>
        <attribute name="action">win.maximize</attribute>
        <attribute name="label" translatable="yes">Maximize</attribute>
      </item>
    </section>
    <section>
      <attribute name="icon">quit</attribute>
      <submenu>
        <attribute name="label" translatable="yes">_About</attribute>
        <attribute name="always-show-images">true</attribute>
        <item>
          <attribute name="label" translatable="yes">_Foo</attribute>
        </item>
      </submenu>
      <item>
        <attribute name="action">app.quit</attribute>
        <attribute name="label" translatable="yes">_Quit</attribute>
        <attribute name="accel">&lt;Primary&gt;q</attribute>
    </item>
    </section>
  </menu>
</interface>
EOC

module RXPP
  class Application < Gtk::Application
    attr_reader :opts
    def initialize
      super 'org.ppibburr.rxpp', Gio::ApplicationFlags::HANDLES_COMMAND_LINE|Gio::ApplicationFlags::HANDLES_OPEN

      options.on "loaded",  "l","signal that plugin has been loaded",  :string
      options.on "unloaded","u","signal that plugin has been unloaded",:string
      
      signal_connect "startup" do
      builder = Gtk::Builder.new(MENU_XML, -1)
      self.set_app_menu(builder.get_object("test"))
      end
      signal_connect :activate do |application|
        w = (application.windows.first || RXPP::UI::ManagerWindow.new(application))
        w.show_all
        w.present   
      end
    end

    def remote_options dict,c
      if plugin=(dict["loaded"] || dict["unloaded"])
        p plugin
        if (w=windows.first)
          GLib::Idle.add do;w.reload;false; end
        end 
        
        0
      else
        super
      end
    end
  end
end



class UIActionMenuBuilder
  def menu id, &b   
    @string << "<menu id=\"#{id}\">"
    instance_exec &b
    @string << "</menu>"
    self
  end
  
  def section id: nil, name: nil,action: nil,label: nil, &b
    @string << "<section>"
    attr(id: id, name: name, label: label, action: action)
    instance_exec &b
    @string << "</section>"
    self
  end
  
  def item id: nil,name: nil,action: nil,label: nil, icon: nil, &b
    @string << "<item>"
    attr(id: id, name: name, label: label, action: action)
    #b.call
    @string << "</item>"
    self
  end

  def submenu id: nil,name: nil,action: nil,label: nil, &b
    @string << "<submenu>"
    attr(id: id, name: name, label: label, action: action)
    instance_exec &b
    @string << "<submenu>"
    self
  end
  
  def attr o={}; 
    o.each_pair do |k,v|
      @string << "<attribute name=\"#{k}\">#{v}</attribute>" if v
    end
  end
  
  def initialize
    @string=""
  end
  
  def to_s; "<interface>"+@string+"</interface>"; end
end

m=UIActionMenuBuilder.new
m.menu(:test) {
  section label: "test" do
    item name: :test, label: "Test" do
    
    end
  end
}

puts MENU_XML = m.to_s
if __FILE__ == $0
  RXPP::Application.new.run [$0]+ARGV
end
