$: << File.expand_path(File.expand_path(__FILE__))

require "xfce4-ui"
require "xfce4-util"

module Xfce4Panel
  class << self
    def const_set c,o
      if c.to_s == c.to_s.downcase
        c = c.to_s.upcase
        super c,o
      else
        super
      end
    end
  end

  class Loader < GObjectIntrospection::Loader
    def initialize(base_module, init_arguments)
      super(base_module)
      @init_arguments = init_arguments
    end

    def load
      self.version = "2.0"
      super("libxfce4panel")
    end
  end
end  
