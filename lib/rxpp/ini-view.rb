$: << File.expand_path(File.dirname(__FILE__))

require "gtk"

module RXPP
  module UI
    class IniView < Gtk::Box
      include Util
      
      attr_reader :ini, :l
      
      def fill()
        o=ini
        
        @ini = {
          Name: "",
          Comment:"",
          :'X-RUBY-File' => "",
          Icon: "application-x-ruby"
        }  
        
        o.each_pair do |k,v| ini[k] = v end

        l.children.each do |c| c.destroy end

        ini.each_pair do |k,v|
          l.add box=Gtk::Box.new(:horizontal,0)

          box.pack_start n=Gtk::Entry.new(),false,false,0
          box.pack_start q=Gtk::Entry.new(),true,true,0

          q.text = "#{v}"
          n.text = "#{k}"

          n.signal_connect "activate" do
            k = edit k,v,q,n,box
            fill
          end

          q.signal_connect "activate" do
            k = edit k,v,q,n,box
            fill
          end
          
          [n,q].each do |_|
            _.signal_connect "focus-in-event" do |_w|
              c = l.children.find do |_| 
                _.children[0].children.index(_w) 
              end
            
              l.select_row c 
            end
            
            _.signal_connect "focus-out-event" do 
              _.select_region 0,0
            end
          end
          
          if (k.to_s =~ /^X\-XFCE/) or k==:Type
            [q,n].each do |_| _.sensitive=false end
          end
        end
        
        show_all
      end
    
      def initialize
        super :vertical, 0
      
        @l =Gtk::ListBox.new
        l.show_all
        l.signal_connect "row-activated" do |_,i|
          i.children[0].children[1].grab_focus
        end

        @f=Gtk::Frame.new("#{file}")
        f.add sw=Gtk::ScrolledWindow.new
        sw.add_with_viewport l
        pack_start f,true,true,3
        
        f=Gtk::Frame.new("Add Entry")
        pack_start f,false,false,3
        
        h=Gtk::Box.new(:horizontal,0)
        f.add h
        h.pack_start n=Gtk::Entry.new,false,false,0
        h.pack_start q=Gtk::Entry.new,true,true,0
        
        n.signal_connect "activate" do 
          @ini[n.text.to_sym] = q.text
          n.text = q.text = ""    
          fill
        end
        
        q.signal_connect "activate" do 
          @ini[n.text.to_sym] = q.text
          n.text = q.text = ""
          fill
        end  
        
        add bb=Gtk::ButtonBox.new(:horizontal)
        
        bb.add @load=b=Gtk::Button.new("document-new",Gtk::IconSize::SMALL_TOOLBAR)  
        b.label="Load"
        b.signal_connect "clicked" do load_plugin @viewing;state(@viewing); end
        
        bb.add @unload=b=Gtk::Button.new("document-close",Gtk::IconSize::SMALL_TOOLBAR)     
        b.label="Unload"
        b.signal_connect "clicked" do Thread.new do;unload(name: @viewing);state(@viewing);false;end; end
        
        bb.add @activate=b=Gtk::Button.new("document-open",Gtk::IconSize::SMALL_TOOLBAR) 
        b.label = "Activate" 
        b.signal_connect "clicked" do activate_plugin(@viewing); apply; state(@viewing); end
        
        bb.add @deactivate=b=Gtk::Button.new("exit",Gtk::IconSize::SMALL_TOOLBAR) 
        b.label = "Deactivate"   
        b.signal_connect "clicked" do deactivate(@viewing); apply;state(@viewing); end  
        
        bb.add @save=b=Gtk::Button.new("document-save",Gtk::IconSize::SMALL_TOOLBAR)
        b.label="Save"
        b.signal_connect "clicked" do save end
        
        bb.add @revert=b=Gtk::Button.new("edit-undo",Gtk::IconSize::SMALL_TOOLBAR)  
        b.label = "Revert"
        b.signal_connect "clicked" do view @viewing end
        
        bb.set_layout Gtk::ButtonBoxStyle::START
        
        GLib::Timeout.add 500 do set_buttons @viewing;false; end
      end
      
      def state n=nil, &b
        if b
          @state_cb = b
        
          return
        end
       
       @state_cb.call(n) if @state_cb
     end
      
     def save   
        a = l = nil
        if @viewing != @ini[:Name]
          a = activated_plugins.index @viewing
          l = loaded_plugins.find do |p| p[:name] == @viewing end
          
          unload name: @viewing

          File.delete(f=get_desktop_file(@viewing))
        end
        
        write_ini @ini
        view @ini[:Name]
        
        activate_plugin @ini[:Name] if a
        apply
        load_plugin @ini[:Name] if l
        
        state @ini[:Name]
      end
      
      def edit k,v,q,n,box
        nk = n.text.strip.to_sym
        k  = k.to_sym
        
        ini.delete(k) if nk != k
        
        if nk == ""
          box.destroy
          return
        end

        ini[nk] = q.text  

        return nk
      end
      
      attr_reader :file,:f,:viewing
      def view n
        @viewing = n
        @ini     = get_ini(@file=get_desktop_file(n))    
        @f.label = file
        
        fill
        
        set_buttons(n)
      end
      
      def set_buttons(n)
        if !loaded_plugins.find do |p| p[:name] == n end
          if !unactivated_plugins.index(n)
            @unload.hide
            @load.show
            @activate.hide
          else
            @unload.hide
            @deactivate.hide
          end
        else
          @deactivate.show
          @activate.hide
        end
      end
    end
  end
end
