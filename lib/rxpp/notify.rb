require 'gobject-introspection'
 
module Notify
  class Loader < GObjectIntrospection::Loader
    def initialize(base_module, init_arguments)
      super(base_module)
      @init_arguments = init_arguments
    end

    def load
      self.version = "0.7"
      super("Notify")
    end
  end
  
  Loader.new(self,[]).load  
end
  

if __FILE__ == $0
Notify.init $0

def msg(summary, body: "", icon: nil, action:nil, &_)
  n=Notify::Notification.new summary,body,icon
  n.add_action action[:name],action[:label], &_ if action
  n.show
  n
end
  
msg "Test Notify", 
    body: "This is a test of libnotify", 
    icon: 'ruby',
    action: {name: 'quit', label: "Test"} do |*p|
  puts :clicked    
end
end
