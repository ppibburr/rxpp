require 'fileutils'
require 'json'
require File.dirname(__FILE__)+"/../rxpp"
puts :utils
module RXPP
  module Util
    def scan_new
      Dir.glob(OUT_DIR+"/*.desktop").find_all do |f|
        (!File.exist?(PLUG_DIR+"/#{File.basename(f)}")) && !File.symlink?(f)
      end
    end

    def manage_new
      scan_new.map do |f|
        `mv #{File.expand_path(f)} #{PLUG_DIR}/`
        f
      end
    end

    def activate_new
      a=[$_rxpp_mn||=[],manage_new].flatten.uniq.map do |f|
        n = get_plugin_field(nil, :Name, file: f)     
        activate_plugin(n)
        n
      end
      $_rxpp_mn = []
      a
    end

    def plugin_ids(panel=1)
      ids = `xfconf-query -c xfce4-panel -p /panels/panel-#{panel}/plugin-ids| grep -v "Value is an\|^$"`.strip.split("\n")[1..-1].find_all do |q| q.strip != "" end.map do |q| q.to_i end
    rescue
      []
    end

    def unload(panel=1, id: nil, name: nil, ids: nil)
       if !ids.is_a?(Array)
         ids = []
         ids = [id] if id
         if name
           loaded_plugins_by_name(name).each do
             remote_event "unload",name
           end
           return
         end
       end

       loaded_plugins.find_all do |p| ids.index(p[:id]) end.each do |p|
         remote_event "unload", p[:name], p[:id]
       end
    end

    def apply()
      `xfce4-panel -r`
      sleep 1
    end

    def names
      a=[]
      Dir.glob("#{PLUG_DIR}/*.desktop").map do |f|
        ff=File.open(f,"r")
        a << ff.read.scan(/Name=(.*)\n/)[0][0]
        ff.close
      end
      a
    end

    def loaded_plugins
      pi = plugin_ids
      ld=`xfconf-query -c xfce4-panel -p /plugins -lv`.split("\n").map do |l| 
       
        l=l.split(" ").uniq.find_all do |q| q end
        a=[l[1..-1].join(" "),l[0].split("-")[-1].to_i]
        a
      end.find_all do |n,i|
        names.index(n) && pi.index(i)
      end.map do |n,i| {name: n, id: i} end
      
      ld
    end

    def loaded_plugins_by_name n
      loaded_plugins.find_all do |o| o[:name]==n end
    end

    def add_plugin(name)
      `xfce4-panel --add="#{name}"`
    end

    def plugins
      names
    end

    def activated_plugins
      Dir.glob("#{OUT_DIR}/*.desktop").find_all do |f| File.exist?(f) end.map do |f|
        _=File.open(f,'r')
        s=_.read.scan(/Name=(.*)\n/)[0][0]
        _.close
        s
      end.find_all do |n| plugins.index(n) end
    end

    def unactivated_plugins
      ap=activated_plugins
      plugins.find_all do |n|
        !ap.index(n) 
      end
    end

    def unloaded_plugins
      lp = loaded_plugins

      activated_plugins.find_all do |n|
        !lp.find do |p| p[:name] == n end
      end
    end

    def load_unloaded
      t=unloaded_plugins.map do |n| 
          add_plugin(n)
      end
      write_conf
    end

    def activate_plugin(n)
      f="#{PLUG_DIR}/#{n}.desktop"
      system "rm \"#{out="#{OUT_DIR}/#{File.basename(f)}"}\""
      system "ln -s \"#{File.expand_path(f)}\" \"#{out}\""
    end

    def deactivate n
      f="#{PLUG_DIR}/#{n}.desktop"
      system "rm \"#{out="#{OUT_DIR}/#{File.basename(f)}"}\""
    end

    def write_ini ini, file: nil
      o = file ||= "#{PLUG_DIR}/#{ini[:Name]}.desktop"
      File.open(o,"w") do |f|
        f.puts """
[Xfce Panel]
        """
        ini.each_pair do |k,v| f.puts "#{k}=#{v}" end
      end
    end

    def create_plugin opts={}
      if opts[:file]
        f=File.expand_path(opts[:file])
        
        n=opts[:name]    ||= File.basename(f)
        c=opts[:comment] ||= "A RubyPlugin (#{f})"
        i=opts[:icon]    ||= "ruby"
        v=opts[:version] ||= "2.0"
        u=opts[:unique]  ||= "FALSE"
        
        ini = {
          Name:    n,
          Comment: c,
          :"X-RUBY-File" => f,
          Icon: i,
          :"X-XFCE-Internal" => "FALSE",
          Type: "X-XFCE-PanelPlugin",
          :"X-XFCE-Module" => "rubyplugin",
          :"X-XFCE-Unique" => u,
          :"X-XFCE-API"    => v,
        }
        
        write_ini(ini)
      end
    end

    def get_desktop_file n
      file=Dir.glob("#{PLUG_DIR}/*.desktop").find do |f|
        true if open(f).read.scan(/Name=(.*)\n/)[0][0] == n
      end

      file = File.expand_path(file)
    end

    def get_ini file
      ini = {}
          
      a = (i=File.open(file,'r')).read.scan(/(.*)\=(.*?)\n/)
      a.each do |k,v| ini[k.to_sym]=v end
      i.close
      ini
    end

    def get_plugin_field n, f, file: nil
      if !file
        file = get_desktop_file(n)
      end
      file = File.expand_path(file)
      
      ini = get_ini(file)
      
      ini[:"#{f}"]
    end

    def edit_plugin opts={}
      ini=get_ini(file=get_desktop_file(opts[:name]))
      
      ini["Comment"]        = opts[:comment] ||= ini["Comment"]
      ini["Icon"]           = opts[:icon]    ||= ini["Icon"]
      ini["X-RUBY-File"]    = opts[:file]    ||= ini["X-RUBY-File"]  
      ini["X-XFCE-API"]     = opts[:version] ||= ini["X-XFCE-API"]
      ini["X-XFCE-Unique"]  = opts[:unique]  ||= ini["X-XFCE-Unique"]
      
      write_ini ini, file: file
    end

    def load_plugin n;
      `xfce4-panel --add=#{n}` 
    end

    def dump
      {
        plugins:     plugins,
        loaded:      loaded_plugins,
        unloaded:    unloaded_plugins,
        activated:   activated_plugins,
        unactivated: unactivated_plugins
      }
    end

    def write_conf panel: 1
      s="-t int -s "
      pi = plugin_ids
      s+=pi.map do |i|
        i.to_s
      end.join(" -t int -s ")

      `xfconf-query -c xfce4-panel -p /panels/panel-#{panel}/plugin-ids -rR`
      `xfconf-query -c xfce4-panel -p /panels/panel-#{panel}/plugin-ids --force-array #{s} --create` if !pi.empty?
    end

    def remote_event event, plugin, id=nil
      Thread.new do
        `xfce4-panel --plugin-event "#{plugin}":#{event}` if !id
        `xfce4-panel --plugin-event "#{plugin}":#{event}:int:#{id}` if id
        if event == "unload"
          `#{ENV["HOME"]}/.local/bin/rxpp.rb -g -- -u #{plugin}`
        end
      end
    end 

    def gui bool=true
      require File.dirname(__FILE__)+"/window"
      
      manage_new

      if !bool
        Gtk.init
      end
      
      w=UI::ManagerWindow.new
      w.signal_connect "delete-event" do
        w.destroy
        bool ? nil : Gtk.main_quit
      end
      
      Gtk.main if !bool
    end
  end
end

