module Xfce4UI
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
      super("libxfce4ui")
    end
  end
  
  Loader.new(self,[]).load
end
