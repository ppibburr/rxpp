namespace Q {
  namespace Browser {

    public class Window : Q.UI.ApplicationWindow {
public  Regex protocol_regex;
      public  Gtk.Entry url_bar;
      public  Session book;
      public  Gtk.Label status_bar;
      public  Q.UI.ToolButton back_button;
      public  Q.UI.ToolButton forward_button;
      public  Q.UI.ToolButton reload_button;
      public  Q.UI.ToolButton new_button;
      public Q.UI.InfoBar find_bar;

      public Window (Application app) {
        Object(application: app);
        this.title = "QBrowser - ";
        set_size_request(1000, 650);
        set_default_size(1000, 650);
        create_widgets();
        connect_signals();
        show_all();
        this.find_bar.hide();

      }

       public   virtual  void create_widgets() {
        var toolbar = new Gtk.HBox(false, 0);
        this.back_button = new Q.UI.ToolButton.from_stock(Q.UI.Stock.GO_BACK);
        this.forward_button = new Q.UI.ToolButton.from_stock(Q.UI.Stock.GO_FORWARD);
        this.reload_button = new Q.UI.ToolButton.from_stock(Q.UI.Stock.REFRESH);
        toolbar.pack_start(this.back_button, false, false, 0);
        toolbar.pack_start(this.forward_button, false, false, 0);
        toolbar.pack_start(this.reload_button, false, false, 0);
        this.url_bar = new Gtk.Entry();
        toolbar.pack_start(this.url_bar, true, true, 0);
        this.new_button = new Q.UI.ToolButton.from_stock(Q.UI.Stock.NEW);
        toolbar.pack_start(this.new_button, false, false, 0);
        this.book = new Session();
        this.status_bar = new Gtk.Label("Welcome");
        this.status_bar.xalign = 0;
        var vbox = new Gtk.VBox(false, 0);
        vbox.pack_start(toolbar, false, true, 0);
        this.find_bar = new Q.UI.InfoBar.with_buttons({"gtk-go-back", 1, "gtk-go-forward", 2, "gtk-cancel", 3, null});
        var find = new Gtk.SearchEntry();
        find.set_hexpand(true);
        this.find_bar.get_content_area().add(find);
        vbox.pack_start(this.find_bar, false, false, 0);
        vbox.pack_start(this.book, true, true, 0);
        vbox.pack_start(this.status_bar, false, true, 0);
        add(vbox);
        this.find_bar.hide();

      }

       public   virtual  void connect_signals() {
        key_press_event.connect((event) => {

          if (((event.key.state & Gtk.accelerator_get_default_mod_mask()) == Gdk.ModifierType.CONTROL_MASK)) {

            if (event.key.keyval == Gdk.Key.q) {
              destroy();
              return (true);

            };

            if (event.key.keyval == Gdk.Key.l) {
              this.url_bar.grab_focus();
              return (true);

            };

          };
          return (false);

        });
        this.url_bar.activate.connect(on_activate);
        this.url_bar.focus_in_event.connect(() => {
          GLib.Idle.add(() => {
            this.url_bar.select_region(0, -1);
            return (false);

          });
          return (true);

        });
        book.page_removed.connect(() => {
          if (book.length == 0) {
            destroy();
          }


        });
        ((Gtk.SearchEntry)this.find_bar.get_content_area().get_children().nth_data(0)).activate.connect(() => {
          var q = ((Gtk.SearchEntry)this.find_bar.get_content_area().get_children().nth_data(0)).text;
          book.current.find_text(q);

        });
        this.find_bar.response.connect((c) => {

          if (c == 3) {
            this.find_bar.hide();
            book.current.get_find_controller().search_finish();
            book.current.get_find_controller().search("", 0, -1);
            book.current.grab_focus();

          }          else {
            var q = ((Gtk.SearchEntry)this.find_bar.get_content_area().get_children().nth_data(0)).text;
            if (book.current.get_find_controller().text != q) {
              book.current.find_text(q);
            }

            if (c == 2) {
              book.current.find_text(q);
            }

            if (c == 1) {
              book.current.get_find_controller().search_previous();
            }


          };

        });
        book.added.connect((web_view) => {
          web_view.grab_focus();
          web_view.notify["title"].connect(() => {
            this.title = @"$(web_view.title) - $("QBrowser")";

          });
          web_view.notify[":favicon"].connect(() => {
            stdout.puts(("favicon").to_string()); stdout.putc('\n');;
            this.url_bar.set_icon_from_pixbuf(Gtk.EntryIconPosition.PRIMARY, Gdk.pixbuf_get_from_surface((Cairo.Surface)web_view.favicon, 0, 0, 24, 24));

          });
          web_view.load_changed.connect((w, e) => {

            if (this.book.current == web_view) {

              if (e == WebKit.LoadEvent.COMMITTED) {
                this.status_bar.label = web_view.get_uri()[0:35];
                this.url_bar.text = web_view.get_uri();
                update_buttons();

              };

            };

          });
          web_view.notify["favicon"].connect(() => {

            if (this.book.current == web_view) {
              set_icon(this.book.current_tab.icon);
              this.url_bar.set_icon_from_pixbuf(Gtk.EntryIconPosition.PRIMARY, get_icon());

            };

          });
          web_view.find.connect(() => {
            this.find_bar.show_all();
            var e = ((Gtk.SearchEntry)this.find_bar.get_content_area().get_children().nth_data(0));
            e.text = "";
            e.grab_focus();

          });

        });
        this.book.view_changed.connect(update_buttons);
        this.back_button.clicked.connect(() => {
          this.book.current.go_back();
          this.book.current.grab_focus();

        });
        this.forward_button.clicked.connect(() => {
          this.book.current.go_forward();
          this.book.current.grab_focus();

        });
        this.reload_button.clicked.connect(() => {
          this.book.current.reload();
          this.book.current.grab_focus();

        });
        this.new_button.clicked.connect(() => {
          this.book.new_tab();

        });
        this.book.create_document.connect((d) => {

          if (Settings.get_default().allow_views_open) {
            var n = new Document.with_related_view(d);
            this.book.append(n);
            return (n);

          }          else {
            return (null);

          };

        });

      }

       public   virtual  void update_buttons() {
        this.url_bar.text = this.book.current.get_uri();
        this.back_button.sensitive = this.book.current.can_go_back();
        this.forward_button.sensitive = this.book.current.can_go_forward();
        set_icon(this.book.current_tab.icon);
        this.url_bar.set_icon_from_pixbuf(Gtk.EntryIconPosition.PRIMARY, get_icon());

      }

       public   virtual  void on_activate() {
        var url = Browser.omni(this.url_bar.text);
        this.book.current.load_uri(url);
        this.book.current.grab_focus();

      }
    }


  }

}
