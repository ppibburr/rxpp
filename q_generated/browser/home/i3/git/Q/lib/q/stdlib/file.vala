




namespace Q {
  public const int FILE_MODE_EXE = 509;
  public enum FileIOMode {
    READ,
    WRITE,
    APPEND,
    READ_WRITE;
  }
  public enum FileModType {
    NONE,
    CHANGE,
    DELETE;
  }








  public static string? read(string f) {
    string? s = null;




    try {
      string? _q21__Q__File__read_pct_rav0_Q__File__read_ss = null;
  if (GLib.FileUtils.test(Q.expand_path(f), GLib.FileTest.EXISTS)) {;
    FileUtils.get_contents(f, out _q21__Q__File__read_pct_rav0_Q__File__read_ss);
  };
;
  
s = _q21__Q__File__read_pct_rav0_Q__File__read_ss;;;
    }     catch (FileError e) {
      return (null);

    }

    return (s);

  }

  public static bool write(string f, string s) {

    try {
      var _q22__Q__File__write_pct_rav0_Q__File__write_exe = GLib.FileUtils.test(f, GLib.FileTest.IS_EXECUTABLE);
        GLib.FileUtils.set_contents(f, s, -1);
        if (_q22__Q__File__write_pct_rav0_Q__File__write_exe) {;
          GLib.FileUtils.chmod(f, Q.FILE_MODE_EXE);
        };;
      return (true);
    }     catch (FileError e) {
      return (false);

    }


  }

   public   string expand_path(string f, string? cwd = null) {
    string?[] _q_local_scope_empty_str_array = new string[0];
    MatchInfo _q_local_scope_match_data = null;

    string? r = null;
    var c = GLib.Environment.get_current_dir() == null ? GLib.Environment.get_current_dir() : GLib.Environment.get_current_dir();

    if ((/^\~\//).match(f, 0, out _q_local_scope_match_data)) {
      r = GLib.Environment.get_home_dir() + "/" + f.split("~/")[1];

    }    else if ((/^\//).match(f, 0, out _q_local_scope_match_data)) {
      r = f;

    }    else {
      r = c + "/" + f;

    };
    var o = new string[0];;
    var i = -1;

    foreach (var q in r.split("/")) {
      if (q == "..") {
        i = i - 1;
      }


      if (q != "..") {
        i += 1;

        if (o.length - 1 < i) {
          o += q;

        }        else {
          o[i] = q;

        };

      };

    };

    return (string.joinv("/", o[0:i + 1]));

  }
  #if Q_FILE

   public   Q.File open(string pth, Q.FileIOMode? m, Q.File.open_cb cb) {

    return (Q.File.open(pth, m, cb));

  }
  #endif

}


