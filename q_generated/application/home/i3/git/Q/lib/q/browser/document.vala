
namespace Q {
  namespace Browser {

    public class Document : WebKit.WebView {
private Settings _s_;

            public  Downloader downloader {
          get {
            return (this._s_.downloader);

          }


        }


      public Document.with_related_view (Document d) {
        Object(user_content_manager: d.user_content_manager, settings: d.get_settings(), related_view: d);
        this._s_ = d._s_;
        bind_keys();

      }

      public Document (Settings? s = null, string? uri = null) {
        var _s = Settings.get_default();
        if (s != null) {
          _s = s;
        }

        var c = _s.web_context;
        var ws = _s.web_settings;
        Object(web_context: c, settings: ws);
        if (uri != null) {
          load_uri(uri);
        }

        this._s_ = s;
        bind_keys();

      }

       public   virtual  void bind_keys() {
        key_press_event.connect((event) => {

          if (((event.key.state & Gtk.accelerator_get_default_mod_mask()) == Gdk.ModifierType.CONTROL_MASK)) {

            if (event.key.keyval == Gdk.Key.f) {
              find();
              return (true);

            };

            if (event.key.keyval == Gdk.Key.minus) {
              this.zoom_level = this.zoom_level - 0.1;
              return (true);

            };

            if (event.key.keyval == Gdk.Key.equal) {
              this.zoom_level = this.zoom_level + 0.1;
              return (true);

            };

            if (event.key.keyval == Gdk.Key.r) {
              reload();
              return (true);

            };
            return (false);

          };
          return (false);

        });

      }

       public   virtual  void find_text(string q) {

        if (get_find_controller().text == q) {
          get_find_controller().search_next();

        }        else {
          get_find_controller().search(q, WebKit.FindOptions.WRAP_AROUND | WebKit.FindOptions.CASE_INSENSITIVE, -1);

        };

      }

       public  signal  void find();
    }


  }

}
