namespace Q {
  namespace Browser {

    public class Application : Q.UI.Application {
public  Window active_window {
          get {
            return ((Window)((Gtk.Application)this).active_window);

          }


        }


      public Application (string n) {
        int? _q_local_scope_process_exit_status = null;

        base(n);
        this.create_window.connect(() => {
          Settings.get_default().web_settings.enable_smooth_scrolling = true;
          var w = new Window(this);
          add_window(w);
          w.book.open("http://google.com");

        });
        mkopts.connect((opts, cl) => {
          opts.summary = "Lightweight WebBrowser written in Q";
          opts.add("extensions-dir", "location to load extensions from", typeof(Q.File)).on.connect((v) => {
            Settings.get_default().web_context.set_web_extensions_directory((string)v);

          });
          opts.add("clobber", "clear cache and cookies").on.connect(() => {
            var pth = Settings.get_default().web_context.website_data_manager.base_cache_directory;
            string cmd; cmd = @"rm -rf $(pth)/*";
            stdout.puts((cmd).to_string()); stdout.putc('\n');;
            Process.spawn_command_line_sync(cmd, null, null, out _q_local_scope_process_exit_status);

          });
          opts.add("user-agent", "set the ua string", typeof(string)).on.connect((v) => {
            Settings.get_default().web_settings.user_agent = (string)v;

          });
          opts.add("allow-views-open-new", "Allow a view to create another view (default is off)", typeof(bool)).on.connect((v) => {
            stdout.puts(((bool)v).to_string()); stdout.putc('\n');;
            Settings.get_default().allow_views_open = (bool)v;

          });

        });
        open_files.connect((fa) => {


          foreach (var a in fa) {
            active_window.book.open(a);

          };


        });

      }
    }


  }

}
