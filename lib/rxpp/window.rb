$: << File.expand_path(File.dirname(__FILE__))

require "gtk"
require "ini-view"
Gtk::Editable
Gio::Application 

module RXPP
  module UI
    class ManagerWindow < Gtk::ApplicationWindow
      include Util
      attr_accessor :loaded,:unloaded,:deactivated
      def lists
        {
          Loaded: pa=loaded_plugins.map do |p| p[:name] end.uniq, 
          Unloaded: activated_plugins.find_all do |p|!pa.index(p) end,
          Deactivated: unactivated_plugins
        }.map do |t,pa|
          l = send(t.to_s.downcase.to_sym)
         
          if !l
            l=Gtk::ListBox.new
            send((t.to_s.downcase+"=").to_sym, l)
          end
          
          l.children.each do |c| c.destroy end
          
          pa.each_with_index do |p, o|
            icon = get_plugin_field(p,:Icon)
            box = Gtk::Box.new(:horizontal, 0)
            l.add box
            box.pack_start i=Gtk::Image.new,false,false,0
            i.set_from_icon_name(icon, Gtk::IconSize::LARGE_TOOLBAR)
            box.pack_start n=Gtk::Label.new(p), true,true,0
            n.set_alignment 0,0
            r=l.get_row_at_index(o)
          end
          
          l.signal_connect "row-activated" do |_,r|
            begin; n = r.children[0].children[1].label
            GLib::Idle.add do @iv.view n
            label.label = @iv.ini[:Comment];false;end
            self.title = "RXPP | PluginManager - #{n}"
            rescue; end
          end  

          l.show_all
          next l,t
        end
      end
      
      attr_reader :label,:img,:iv
      def initialize *o
        $_rxpp_mn=manage_new
      
        super *o
         
        comment=Gtk::Frame.new("About")
        comment.add v=Gtk::Box.new(:vertical, 0)
        
        v.pack_start @img=Gtk::Image.new(),false,false,12
        img.set_from_icon_name "application-x-ruby",Gtk::IconSize::LARGE_TOOLBAR
       
        v.pack_start @label=Gtk::Label.new,false,false,15
        v.pack_start @iv = IniView.new,true,true,5

        @iv.state do |n|
          reload
          @iv.view n
          self.title = "RXPP | PluginManager - #{n}"
        end

        label.set_alignment 0.5,0
        
        w  = Gtk::Window.new :toplevel
        lv = Gtk::Box.new :vertical,0
        
        lists().each do |l,n|
          lf=Gtk::Frame.new(n.to_s)
          lf.add l
          
          lv.pack_start lf,true,true,3
        end
        
        resize 850,480
        
        h=Gtk::Box.new :horizontal, 0
        h.pack_start lv,false,false,2
        h.pack_start comment, true,true,2
        
        add h
        self.set_titlebar(h=Gtk::HeaderBar.new());
        h.show_close_button = true
        self.title = $0
        lbl_variant = GLib::Variant.new("String 1")
        lbl_action = Gio::SimpleAction.new("change_label", lbl_variant.type(),
                                               lbl_variant)
        lbl_action.signal_connect("change-state") do |q| p q; end
        self.add_action(lbl_action)
        
        @loaded.signal_emit "row_activated",loaded.children[0] if loaded.children[0]
      end
      
      def reload
        lists
        l,c = name2list_item(@iv.viewing)
        p l,c
        l.select_row(c) if c
      end  

      def name2list_item name
        [@loaded,@deactivated,@unloaded].each do |l|
          l.children.find do |c| ;p c.children[0].children[1].label; p name
            if c.children[0].children[1].label == name
              return [l,c]
            end
          end
        end
        return nil
      end
    end
  end
end
