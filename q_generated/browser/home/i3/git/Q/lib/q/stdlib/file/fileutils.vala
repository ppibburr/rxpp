
#if Q_FILE





namespace Q {






  public class File {
public   virtual  delegate void open_cb(Q.File? f = null);
    private string _path_name;
    public string path_name {get { return this._path_name;}}

    public File (string? path = null, Q.FileIOMode? mode = null, open_cb? cb = null) {
      this._path_name = path;
      #if Q_FILE_INFO
      refresh();
      #endif
      if (cb != null) {
        cb(this);
      }

      #if Q_FILE_INFO
      if (cb != null) {
        refresh();
      }

      #endif

    }

    public static Q.File? open(string path, Q.FileIOMode? mode = null, open_cb? cb = null) {

      if (!GLib.FileUtils.test(Q.expand_path(path), GLib.FileTest.EXISTS)) {

        if (mode != Q.FileIOMode.READ) {
          Q.write(path, "");

        }        else {
          return (null);

        };

      };
      return (new Q.File(path, mode, cb));

    }

     public   virtual  void replace(string s) {
      Q.write(path_name, s);
      #if Q_FILE_INFO
      refresh();
      #endif

    }

     public   virtual  string? read() {
      return (Q.read(path_name));

    }
    #if Q_FILE_INFO
    private string? _etag;
    public string? etag {get { return this._etag;}}
    private Q.FileModType _modification_type;
    public Q.FileModType modification_type {get { return this._modification_type;}}

     public   virtual  void refresh() {

      if (GLib.FileUtils.test(Q.expand_path(path_name), GLib.FileTest.EXISTS)) {
        this._etag = @"$(mtime):$(ctime)";

      }      else {
        this._etag = null;

      };
      this._modification_type = Q.FileModType.NONE;

    }

     public   virtual  bool check() {

      if ((this._etag != null) && !GLib.FileUtils.test(Q.expand_path(path_name), GLib.FileTest.EXISTS)) {
        this._modification_type = Q.FileModType.DELETE;
        modified(Q.FileModType.DELETE);
        deleted();
        return (true);

      }      else if ((@"$(mtime):$(ctime)" != this.etag)) {
        this._modification_type = Q.FileModType.CHANGE;
        modified(Q.FileModType.CHANGE);
        return (true);

      };
      return (false);

    }




        public  Time mtime {
        get {
          return (Time.local(Stat(path_name).st_mtime));

        }


      }


        public  Time atime {
        get {
          return (Time.local(Stat(path_name).st_atime));

        }


      }


        public  Time ctime {
        get {
          return (Time.local(Stat(path_name).st_ctime));

        }


      }

    #endif

     public  signal  void modified(Q.FileModType mt);

     public  signal  void deleted();

     public   virtual  string basename(string f) {
      return (f.split("/")[f.split("/").length-1]);

    }
  }


}
#endif
