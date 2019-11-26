namespace Q {
  namespace Browser {

    public class Settings {
private WebKit.Settings _web_settings;
      public WebKit.Settings web_settings {get { return this._web_settings;}}
      private WebKit.WebContext _web_context;
      public WebKit.WebContext web_context {get { return this._web_context;}}
            public bool allow_views_open {get;set;}
      private Downloader _downloader;
      public Downloader downloader {get { return this._downloader;}}
      private static Settings __default;

      public Settings () {
        this._web_context = new WebKit.WebContext.with_website_data_manager(new WebsiteDataManager(GLib.Environment.get_user_cache_dir() + @"/$(GLib.Environment.get_prgname())"));
        this._downloader = new Downloader(web_context);
        this._web_settings = new WebKit.Settings();
        this._allow_views_open = false;
        web_settings.enable_developer_extras = true;
        web_settings.enable_webgl = true;
        web_settings.enable_plugins = true;
        web_settings.user_agent = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:64.0) Gecko/20100101 Firefox/64.0";
        var cf = web_context.website_data_manager.base_cache_directory + "/cookies.txt";
        web_context.get_cookie_manager().set_persistent_storage(cf, WebKit.CookiePersistentStorage.TEXT);
        web_context.set_favicon_database_directory(null);
        downloader.add.connect((d) => {
          stdout.puts(("Download").to_string()); stdout.putc('\n');;

        });
        downloader.complete.connect((d) => {
          stdout.puts((@"Download COMPLETE: $(d.get_destination()).").to_string()); stdout.putc('\n');;

        });

      }

      public static Settings get_default() {
        if ( __default == null) {
           __default = new Settings();
        };

        return (__default);

      }
    }


    public class WebsiteDataManager : WebKit.WebsiteDataManager {
public WebsiteDataManager (string base_cache_directory) {
        Object(base_cache_directory: base_cache_directory, base_data_directory: base_cache_directory);

      }
    }


  }

}
