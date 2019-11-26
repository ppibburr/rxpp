#!/usr/bin/ruby

require 'optparse'
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/rxpp.rb"
require "rxpp/utils"

include RXPP::Util
$rxpp_mn=manage_new

opts = {}
parser=OptionParser.new do |o|
  o.banner = """Usage: rxpp.rb [options]

Examples
============= 
rxpp.rb --create --file=~/foo.rb # this will create a plugin named 'foo.rb' wrapping ~/foo.rb 
rxpp.rb -c -f ~/foo.rb -n bar    # this will create a plugin named 'bar' wrapping ~/foo.rb
rxpp.rb -a -n bar                # this will show the plugin in the panel plugin add dialog
rxpp.rb -d -n bar                # Deactivate a plugin and remove from panel
rxpp.rb -L -n bar                # Load a plugin to the panel
rxpp.rb -L                       # Load all unloaded plugins

options
"""
  o.on("-I", "--init", "init manager system. internal, dont use") do |v|
    opts[:init] = v
  end

  o.on("-v", "--version=", "use with -c or -e, xfc4panel version [2.0]") do |v|
    opts[:version] = v
  end
  
  o.on("-c", "--create", "Create a plugin") do |v|
    opts[:create] = v
  end 
  
  o.on("-a", "--activate", "Activate a plugin") do |v|
    opts[:activate] = v
  end   
  
  o.on("-d", "--de-activate", "De-activate a plugin") do |v|
    opts[:deactivate] = v
  end     
  
  o.on("-L", "--load", "Load a plugin") do |v|
    opts[:load] = v
  end    
  
  o.on("-n", "--name=", "specify pluign name") do |v|
    opts[:name] = v
  end  
  
  o.on("-f", "--file=", "use with -c or -e, The ruby file to run as plugin") do |v|
    opts[:file] = v
  end  
  
  o.on("-u", "--unique=", "use with -c or -e, Allow more than one instance of plugin") do |v|
    opts[:file] = v
  end  
  
  o.on("-e", "--edit", "edit plugin (requires -n NAME)") do |v|
    opts[:edit] = v
  end   
  
  o.on("-i", "--icon=", "use with -c or -e, The ICON to display in manager") do |v|
    opts[:icon] = v
  end  
  
  o.on("-C", "--comment=", "use with -c or -e, The comment.") do |v|
    opts[:comment] = v
  end       
  
  o.on("-V", "--view", "Read contents of --name=NAME desktop file") do |v|
    opts[:view] = v
  end 
  
  o.on("-D", "--dumo", "Display information") do |v|
    opts[:dump] = v
  end    
  
  o.on("-U", "--remove", "remove --name=NAME from panel") do |v|
    opts[:remove] = v
  end   
  
  o.on("-N", "--scan-new", "Manage new installed plugins") do |v|
    opts[:new] = v
  end     
  
  o.on("-g", "--gui", "GUI Manager Interface") do |v|
    opts[:gui] = v
  end     
  
  o.on("--log=", "View log for ID") do |v|
    opts[:log] = v
  end                      
end.parse!

if opts[:create]
  create_plugin opts

elsif opts[:edit]
  edit_plugin(opts); apply
end

if opts[:remove]
  if n=opts[:name]
    unload(name: n)
  else
    pa=loaded_plugins
    t=pa.map do |p|
      unload(name: p[:name])
    end
  end  
  write_conf
end

if opts[:activate]
  if n=opts[:name]
    activate_plugin(n)
  else
    unactivated_plugins.each do |n| activate_plugin n end
  end
  
  apply;sleep 1
end

if opts[:deactivate]
  if n=opts[:name]
    deactivate(n)
  else
    plugins.each do |n| deactivate(n) unless opts[:name]=="ruby-plugin-manager.rb" end
  end
  
  apply
end

if opts[:new]
  activate_new.each do |n|
    puts "Loading new plugin: #{n}"
    system "ruby #{__FILE__} --view -n \"#{n}\""
    system "ruby #{__FILE__} -a -L -n \"#{n}\""  
  end
end

if opts[:load]
  if n=opts[:name]
    load_plugin(n)
  elsif !unloaded_plugins.empty?
    load_unloaded;
  end  
end

if opts[:create] or opts[:edit] or opts[:view]
  file=Dir.glob("#{RXPP::PLUG_DIR}/*.desktop").find do |f|
    s= File.open(f,"r").read
    s.scan(/Name=(.*)\n/)[0][0] == opts[:name]
  end
  file = File.expand_path(file)
  puts open(file).read
end

if opts[:init]
  FileUtils.mkdir_p dest="#{ENV["HOME"]}/.local/bin/"
  `cp #{File.expand_path(__FILE__)} #{dest}`
  FileUtils.mkdir_p dest="#{ENV["HOME"]}/.local/lib/rxpp/"
  
  puts c="cp #{File.expand_path(File.dirname(__FILE__))}/../lib/rxpp.rb #{File.join(dest,"..")}"
  `#{c}`
  
  Dir.glob("#{File.expand_path(File.dirname(__FILE__))}/../lib/rxpp/*.rb").each do |src| 
    puts c="cp #{src} #{dest}";
    puts `#{c}` 
  end
  
  src="#{File.expand_path(File.dirname(__FILE__))}/../plugins/ruby-plugin-manager.rb"
  m  ="#{RXPP::PLUG_DIR}/ruby-plugin-manager/lib/#{File.basename(src)}"
  FileUtils.mkdir_p File.dirname(m)
  puts x="cp #{src} #{m}"
  puts `#{x}`
  
  system "ruby #{__FILE__} -c -f #{m} -C 'Plugin to manage and autoload Ruby xfce4-panel-plugins'"
  system "ruby #{__FILE__} -a -L -n #{n=File.basename(m)}"
end


if opts[:dump]
  puts "\n"; puts JSON.pretty_generate(dump)
end


if opts[:gui]
  require File.expand_path(File.dirname(__FILE__)+"/../lib/rxpp/application.rb")
  RXPP::Application.new.run([$0]+ARGV)
end

if id=opts[:log] 
  if plugin = loaded_plugins.find do |p| p[:id] == id.to_i end
    system "tail -F #{RXPP::PLUGIN_LOG_DIR}/#{plugin[:name]}/#{id}.log"
  end
end
