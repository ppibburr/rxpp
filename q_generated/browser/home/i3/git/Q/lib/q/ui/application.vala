namespace Q {
  namespace UI {

    public class Application : Gtk.Application {
public bool quit_on_last_window_exit = true;

            public  ApplicationWindow active_window {
          get {
            return ((ApplicationWindow)((Gtk.Application)this).active_window);

          }


        }


      public Application (string? n = null) {
        var flags = GLib.ApplicationFlags.HANDLES_OPEN | GLib.ApplicationFlags.HANDLES_COMMAND_LINE;
        Object(application_id: n, flags: flags);
        this.activate.connect(() => {
          if (get_windows().length() > 0) {
            return;
          }

          create_window();

        });
        this.command_line.connect((cl) => {
          var opts = new Opts();
          mkopts(opts, cl);
          var a = opts.parse(cl.get_arguments());
          GLib.Idle.add(() => {
            open_files(a);
            return (false);

          });
          register();
          activate();

          for (int i = 0; i <= cl.ref_count; i++) {
            cl.unref();

          }

          return (0);

        });
        mkopts.connect((opts, cl) => {
          opts.summary = "";
          opts.add("help", "Show this message").on.connect(() => {
            cl.print(opts.help());
            if (get_windows().length() <= 0) {
              exit(0);
            }


          });

        });

      }

       public  signal  void create_window();

       public  signal  void open_files(string[] a);

       public  signal  void mkopts(Opts opts, ApplicationCommandLine cl);
    }


  }

}
