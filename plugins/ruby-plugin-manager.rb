require "rxpp/utils"
require "rxpp/window"

class MenuItem < Gtk::ImageMenuItem
  attr_reader :name, :icon, :button
  attr_accessor :id
  def initialize name='plugin item', icon='application-x-ruby', id: nil
    super()

    h= Gtk::Box.new :horizontal, 0
    h.add @button=c=Gtk::CheckButton.new

    set_image i=Gtk::Image.new
    i.set_from_icon_name icon, Gtk::IconSize::MENU

    h.add l=Gtk::Label.new(@name=name)
    
    add h
    show_all
  
    signal_connect "activate" do
      toggle
    end
  end  
  
  def toggle
    @button.active = !@button.active?
    RXPP::Plugin.default.remote_event :unload, name, id
  rescue => e
    print_err e
  end
end

def x *o
  o=o.map do |q| q = "-#{q}" if q.is_a?(Symbol); q end
  RXPP::Plugin.default.log x: c="#{ENV['HOME']}/.local/bin/rxpp.rb #{o.join(" ")}"
  `#{c}`
end

def menu_item t=:item, label: "", icon: nil
  case t
  when :item
    i=Gtk::MenuItem.new(label)
    i.show_all
    i
  when :separator
    i=Gtk::SeparatorMenuItem.new
    i.show
    i
  when :checked
    i=Gtk::CheckMenuItem.new(label)
    i.show
    i
  when :check_img
    i = MenuItem.new(label,icon)
    i.show_all
    i
  when :image
    i = Gtk::ImageMenuItem.new(label)
    i.set_image img=Gtk::Image.new
    img.set_from_icon_name icon,Gtk::IconSize::MENU
    i.show
    i
  end
  
  return i
rescue => e
  print_err e
end

def browse;
  fork do x :g end
rescue => e;print_err e
end

plugin() do
  include RXPP::Util
end.run() do
  $_rxpp_mn=manage_new
  
  add l=Xfce4Panel::PanelImage.new("app-launcher")
  
  l.tooltip_markup = get_plugin_field(File.basename(__FILE__), :Comment)
  l.show;
  l.set_size Gtk::IconSize::MENU
  
  event "plugin-loaded" do |e,v|
    log evt: [e,v]
  end
  
  menu_insert_item menu_item :separator
  menu_insert_item i=menu_item(:checked, label: "Auto load")
  i.active = !!self[:autoload]
  i.signal_connect "activate" do self[:autoload] = true end
  menu_insert_item menu_item :separator
  menu_insert_item $lm=menu_item(:image, icon: 'document-import', label: "Load")
  menu_insert_item $am=menu_item(:image, icon: 'dialog-apply', label: "Activate")
  menu_insert_item $dm=menu_item(:image, icon: 'exit', label: "Deactivate")
  menu_insert_item menu_item :separator
  menu_insert_item i=menu_item(label: "Unload All")
  i.signal_connect("activate") do 
    x :U
  end
  menu_insert_item i=menu_item(label: "Deactivate All")
  i.signal_connect("activate") do 
    x :d
  end
  menu_insert_item menu_item :separator
  
  items=[]
  
  clicked do; browse ;end
  notify "Ok", action: {name: "foo", label: "foo"} do
    log action: :foo
  end.show
  popup do;
    begin
      GLib::Idle.add do
        $lm.submenu=m=Gtk::Menu.new
    
        activated_plugins.each do |p|
          next if p == File.basename(__FILE__)
          m.append pi=menu_item(:image, label: p, icon: get_plugin_field(p,:Icon))
          pi.tooltip_markup = get_plugin_field(p,:Comment)    
          pi.signal_connect "activate" do log activate: p;x :L, :n, "\"#{p}\"" end
        end
      
        $am.submenu=m=Gtk::Menu.new
        unactivated_plugins.each do |p|
          m.append pi=menu_item(:image, label: p, icon: get_plugin_field(p,:Icon))
          pi.tooltip_markup = get_plugin_field(p,:Comment)
          pi.signal_connect "activate" do activate_plugin(p);apply end
        end  
        
        $dm.submenu=m=Gtk::Menu.new
        activated_plugins.each do |p|
          next if p == File.basename(__FILE__)
          m.append pi=menu_item(:image, label: p, icon: get_plugin_field(p,:Icon))
          pi.tooltip_markup = get_plugin_field(p,:Comment)
          pi.signal_connect "activate" do unload(p);write_conf;deactivate(p);apply end
        end      

       false
      end

      items.each do |i| i.destroy rescue nil;end
      items = [m=Gtk::MenuItem.new("Debug")]
      m.submenu = Gtk::Menu.new
      loaded_plugins.map do |p|
        begin
          next p if p[:name] == File.basename(__FILE__)
          i=menu_item :check_img, label: p[:name], icon: get_plugin_field(p[:name], :Icon)
          i.id = p[:id].to_i
          items << i
          menu_insert_item(i)
        
          i.button.active  =true
          i.tooltip_markup = get_plugin_field(p[:name],:Comment)
        rescue => e; 
          print_err e;
        end  
        
        p
      end.each do |p|
        m.submenu.children.each do |c| c.destroy end
        m.submenu.append te=Gtk::MenuItem.new(p[:name])
        
        te.signal_connect "activate" do
          remote_event 'show-console',p[:name], p[:id]
        end
        
        te.show
      end

      items << i=menu_item(:separator)
      menu_insert_item(i)
 
      menu_insert_item m;m.show
      
      items << i=menu_item(:separator)
      menu_insert_item(i)
      
      i = menu_item(:image, label: "Reload", icon: "reload")
      items << i
      menu_insert_item(i)
      i.signal_connect "activate" do `xfce4-panel -r` end
    rescue => e
      print_err e
    end 
   false
  end

  if self[:autoload]
    GLib::Timeout.add(15) do
      begin
      `#{ENV['HOME']}/.local/bin/rxpp.rb -N -L`
      rescue => e;
        print_err e;
      end
      false
    end  
  end
end

