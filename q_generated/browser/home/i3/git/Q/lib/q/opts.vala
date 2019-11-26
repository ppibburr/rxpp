


using Q;






public class Opts {
public class Option {
public  string? desc;
    public  string? name;
    public  string? short_name;
    public Type? vtype;
    public Value? value;

    public Option (string n, string? d = null, Type? t = null, Value? v = null) {
      this.desc = d;
      this.name = n;
      this.vtype = t;
      this.value = v;

    }

     public   virtual  void parse(string v) {
      if (vtype == typeof(int)) {
        this.value = int.parse(v);
      }

      if (vtype == typeof(bool)) {
        this.value = bool.parse(v);
      }

      if (vtype == typeof(float)) {
        this.value = v.to_double();
      }

      if (vtype == typeof(double)) {
        this.value = v.to_double();
      }

      if (vtype == typeof(string)) {
        this.value = v;
      }

      if (vtype == typeof(Q.File)) {
        this.value = v;
      }


    }

     public  signal  void on(Value? v = null);
  }

  public  string? program;
  public  string? summary;

  public Opts () {
    this.opts = new Hash<Option>();
    Option h = add("help", "Show help message.");
    h.short_name = "h";

  }
  public Hash<Option> opts;

   public   virtual  Option add(string n, string? desc = null, Type? t = null, Value? v = null) {
    this.opts[n] = new Option(n, desc, t, v);
    return (this.opts[n]);

  }






   public   virtual  string[] parse(string[] argv) {
    string?[] _q_local_scope_empty_str_array = new string[0];
    MatchInfo _q_local_scope_match_data = null;

    this.program = argv[0];
    var aa = new string[0];;






    for (int i = 0; i <= (argv.length - 1); i++) {

      if (i != 0) {
        Opts.Option? o = null;
        var a = argv[i];






        if ((/^\-\-(.*?)\=(.*)/).match(a, 0, out _q_local_scope_match_data)) {
          o = this.opts[(_q_local_scope_match_data != null ? _q_local_scope_match_data.fetch(1) : _q_local_scope_empty_str_array[0])];
          if (o == null) {
            invalid((_q_local_scope_match_data != null ? _q_local_scope_match_data.fetch(1) : _q_local_scope_empty_str_array[0]));
          }

          if (o != null) {
            o.parse(Shell.unquote((_q_local_scope_match_data != null ? _q_local_scope_match_data.fetch(2) : _q_local_scope_empty_str_array[0])));
          }


        }        else if ((/^\-\-(.*)/).match(a, 0, out _q_local_scope_match_data)) {
          o = this.opts[(_q_local_scope_match_data != null ? _q_local_scope_match_data.fetch(1) : _q_local_scope_empty_str_array[0])];
          if (o == null) {
            invalid((_q_local_scope_match_data != null ? _q_local_scope_match_data.fetch(1) : _q_local_scope_empty_str_array[0]));
          }


        }        else if ((/^\-(.*)/).match(a, 0, out _q_local_scope_match_data)) {
          opts.for_each((k, v) => {
            if (v.short_name == (_q_local_scope_match_data != null ? _q_local_scope_match_data.fetch(1) : _q_local_scope_empty_str_array[0])) {
              o = v;
            }

            if (o != null) {
              return;
            }


          });
          if (o == null) {
            invalid((_q_local_scope_match_data != null ? _q_local_scope_match_data.fetch(1) : _q_local_scope_empty_str_array[0]));
          }


        }        else {
          aa += a;

        };
        if (o != null) {
          o.on(o.value);
        }


      };

    }

    return (aa);

  }

   public   virtual  string type_name(string o) {

    if (opts[o].vtype == typeof(string)) {
      return ("STRING");

    }    else if (opts[o].vtype == typeof(Q.File)) {
      return ("FILE");

    }    else if (opts[o].vtype == typeof(bool)) {
      return ("BOOL");

    }    else if (opts[o].vtype == typeof(int)) {
      return ("INTEGER");

    }    else if (opts[o].vtype == typeof(double)) {
      return ("DOUBLE");

    }    else if (opts[o].vtype == typeof(float)) {
      return ("FLOAT");

    };
    return (opts[o].vtype.name());

  }

   public   virtual  Option? option(string o) {
    return (opts[o]);

  }

   public   virtual  string help() {
    string s; s = "";
    s += hint + @"  
    
$(summary == null ? "" : summary)    
    ";
    s += "\nOPTIONS";


    foreach (var o in opts.keys) {

      if (opts[o].vtype == null) {
        s += "\n  %-40s %s".printf(@"$(opts[o].short_name != null ? "-" + opts[o].short_name + ", " : "")--" + opts[o].name, opts[o].desc);

      }      else {
        s += "\n  %-40s %s".printf(@"--$(opts[o].name)=$(type_name(o))", opts[o].desc);

      };

    };

    s += "\n";
    return (s);

  }

   public   virtual  Option? get(string o) {
    return (this.opts[o]);

  }

   public   virtual  void set(string o, Option? v = null) {
    this.opts[o] = v;

  }

   public   virtual  bool contains(string o) {
    return (o in opts.keys);

  }
  private string? _hint;

    public  string hint {
      owned get {

        return (this._hint == null ? @"Usage:  $(program) [OPTIONS] [FILEs]" : this._hint);

      }

      set {
        this._hint = value;

      }


    }


   public  signal  void invalid(string s);
}

#if Q_TEST

 public   void main(string[] argv) {
  var opts = new Opts();
  opts.summary = "An example program.";
  opts["help"].on.connect(() => {
    stdout.puts((opts.help()).to_string()); stdout.putc('\n');;
    exit(0);

  });

  var o = opts.add("test-int", "test int value.", typeof(int)).on.connect((v) => {
  if (v != null) {
    stdout.puts(((int)v).to_string()); stdout.putc('\n');;
  }


});

  Value d;
  d = 5;

   o = opts.add("test-int-def", "test int value.", typeof(int), d).on.connect((v) => {
  if (v != null) {
    stdout.puts(((int)v).to_string()); stdout.putc('\n');;
  }


});


   o = opts.add("test-str", "test str value.", typeof(string)).on.connect((v) => {
  if (v != null) {
    stdout.puts((Q.expand_path((string)v)).to_string()); stdout.putc('\n');;
  }


});


   o = opts.add("test-file", "test file value.", typeof(Q.File)).on.connect((v) => {
  if (v != null) {
    stdout.puts((Q.expand_path((string)v)).to_string()); stdout.putc('\n');;
  }


});

  opts.invalid.connect((o) => {
    stdout.puts((@"Invalid option: $(o)").to_string()); stdout.putc('\n');;
    exit(1);

  });

  foreach (var f in opts.parse(argv)) {
    stdout.puts((@"FILE: $(f)").to_string()); stdout.putc('\n');;

  };

  stdout.puts(((int)opts.option("test-int-def").value).to_string()); stdout.putc('\n');;

}
#endif
