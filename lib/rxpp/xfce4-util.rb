module Xfce4Util
  extend FFI::Library
  
  ffi_lib "xfce4util"
  
  attach_function :xfce_rc_write_entry,[:pointer, :string, :string], :void
  attach_function :xfce_rc_read_entry,[:pointer, :string, :string], :string
  attach_function :xfce_rc_simple_open,[:string,:bool], :pointer
  attach_function :xfce_rc_flush, [:pointer],:void
  
  class Rc
    attr_reader :ptr
    def initialize ptr
      @ptr = ptr
    end
    def self.simple_open s,b=false
      new Xfce4Util.xfce_rc_simple_open(s,b)
    rescue => e; print_err e;
    end
    def write_entry n, v
      Xfce4Util.xfce_rc_write_entry ptr,n,v
    end
    def read_entry n, fb
      Xfce4Util.xfce_rc_read_entry ptr,n,fb
    end  
    def flush
      Xfce4Util.xfce_rc_flush(ptr)
    end    
  end
end
