require "fileutils"

$: << File.expand_path(File.dirname(__FILE__))

module RXPP
  PLUGIN_LOG_DIR = File.expand_path("#{ENV["HOME"]}/.local/share/rxpp/plugins/logs/")
  FileUtils.mkdir_p PLUGIN_LOG_DIR
  
  FileUtils.mkdir_p PLUG_DIR="#{ENV["HOME"]}/.local/share/rxpp/plugins"
  OUT_DIR = File.expand_path("~/.local/share/xfce4/panel/plugins/")

  FileUtils.mkdir_p(OUT_DIR)
end
