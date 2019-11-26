namespace Q {
  namespace UI {

    public class Tabbed<T> : Gtk.Notebook {
public class Tab : Gtk.HBox {
private Gtk.Label _label_widget;
        public Gtk.Label label_widget {get { return this._label_widget;}}
        private Gtk.Image _icon_widget;
        public Gtk.Image icon_widget {get { return this._icon_widget;}}
        private Q.UI.Button _close;
        public Q.UI.Button close {get { return this._close;}}

                public  string label {
            owned get {

              return (this.label_widget.label);

            }

            set {
              this.label_widget.label = value;

            }


          }


                public  Gdk.Pixbuf? icon {
            get {
              return (this.icon_widget.get_pixbuf());

            }

            set {
              this.icon_widget.set_from_pixbuf(value);

            }


          }


        public Tab () {
          this._label_widget = new Gtk.Label("");
          this._label_widget.ellipsize = Pango.EllipsizeMode.END;
          this._close = new Q.UI.Button.from_stock(Q.UI.Stock.CLOSE);
          this._close.relief = Gtk.ReliefStyle.NONE;
          this._icon_widget = new Gtk.Image();
          pack_start(this.icon_widget, false, false, 1);
          pack_start(this.label_widget, true, true, 0);
          pack_start(this.close, false, false, 0);
          show_all();

        }
      }

      private Hash<T?> _named;

      public Tabbed () {
        Object();
        this._named = new Hash<T?>();
        key_press_event.connect((event) => {

          if (((event.key.state & Gtk.accelerator_get_default_mod_mask()) == Gdk.ModifierType.CONTROL_MASK)) {

            if (event.key.keyval == Gdk.Key.n) {
              new_tab();
              return (true);

            };

            if (event.key.keyval == Gdk.Key.t) {
              cycle_tab();
              return (true);

            };
            return (false);

          };
          return (false);

        });
        switch_page.connect(() => {
          GLib.Idle.add(() => {
            view_changed();
            return (false);

          });

        });

      }

       public   virtual  void append(T t) {
        var tl = new Tab();
        append_page((Gtk.Widget)t, tl);
        ((Gtk.Widget)t).show();
        added(t);
        tl.close.clicked.connect(() => {
          remove(t);

        });
        set_tab_detachable((Gtk.Widget)t, true);
        this.page = -1;
        Value v;
        v = true;
        child_set_property((Gtk.Widget)t, "tab-expand", v);

      }

       public   virtual  void remove(T t) {


        for (int i = 0; i <= length - 1; i++) {

          if (get(i) == t) {
            remove_page(i);
            removed(t);

          };

        };


      }

       public   virtual  void cycle_tab() {
        var i = this.page + 1;
        if (i > length - 1) {
          i = 0;
        }

        this.page = i;

      }

       public  signal  void removed(T v);

       public  new virtual  T get(int i) {
        return ((T)get_nth_page(i));

      }

       public  new virtual  void set(int i, T v) {
        insert_page((Gtk.Widget)v, new Tab(), i);

      }

            public  int length {
          get {
            return (get_n_pages());

          }


        }


            public  T view {
          set {


            for (int i = 0; i <= (length - 1); i++) {
              if (get(i) == value) {
                this.page = i;
              }


            }


          }

          owned get {

            return (current);

          }


        }


       public  signal  void added(T v);

       public  signal  void new_tab();

       public  signal  void view_changed();

            public  T current {
          owned get {

            return (get(get_current_page()));

          }


        }


            public  Tab current_tab {
          owned get {

            return ((Tab)get_tab_label((Gtk.Widget)current));

          }


        }


       public   virtual  Tab get_tab(T t) {
        return ((Tab)get_tab_label((Gtk.Widget)t));

      }

       public   virtual  delegate void each_cb<T>(T w);

       public   virtual  void each_view(each_cb cb) {


        for (int i = 0; i <= (length - 1); i++) {
          cb(get(i));

        };


      }

       public   virtual  bool contains(T v) {
        bool c; c = false;
        each_view((w) => {

          if (v == w) {
            c = true;
            return;

          };

        });
        return (c);

      }

       public   virtual  void set_named(string n) {
        if (this._named[n] != null) {
          this.view = this._named[n];
        }


      }

       public   virtual  T? get_named(string n) {
        return (this._named[n]);

      }

       public   virtual  string? get_name(T w) {
        string? n = null;

        foreach (var k in this._named.keys) {

          if (this._named[k] == w) {
            n = k;
            return (n);

          };

        };

        return (n);

      }

       public   virtual  Iterator<T> iterator() {
        return (new Iterator<T>(this));

      }

      public class Iterator<T> {
private int _index = 0;
        private Tabbed<T> _tabbed;

        public Iterator (Tabbed<T> t) {
          this._tabbed = t;

        }

         public   virtual  bool next() {
          return (this._index < this._tabbed.length);

        }

         public   virtual  T get() {
          _index += 1;
          return (_tabbed.get(_index-1));

        }
      }
    }


  }

}
