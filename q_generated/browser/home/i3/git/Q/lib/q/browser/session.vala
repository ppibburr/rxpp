namespace Q {
  namespace Browser {

    public class Session : Q.UI.Tabbed<Document> {
public   virtual  void open(string u = "http://google.com") {
        var doc = new Document(Settings.get_default());
        doc.load_uri(Browser.omni(u));
        append(doc);
        doc.show();
        doc.notify["title"].connect(() => {
          get_tab(doc).label = doc.title;
          if (doc.title.length > 35) {
            get_tab(doc).label = doc.title[0:35];
          }


        });
        this.group_name = "any";
        create_window.connect((w, x, y) => {
          Application app = (Application)GLib.Application.get_default();
          var n = new Window(app);
          app.add_window(n);
          weak Session wk;
          wk = n.book;
          return (wk);

        });

      }

      public Session () {
        base();
        new_tab.connect(() => {
          open();

        });
        removed.connect((v) => {
          v.destroy();

        });
        added.connect((d) => {
          d.notify["title"].connect(() => {
            get_tab(d).label = d.title;

          });
          d.notify["favicon"].connect(() => {
            Cairo.ImageSurface? surface = null; surface = (Cairo.ImageSurface?)d.get_favicon();

            if (surface != null) {
              get_tab(d).icon = Gdk.pixbuf_get_from_surface(surface, 0, 0, surface.get_width(), surface.get_height());

            };

          });
          d.create.connect(() => {
            return (create_document(d));

          });

        });

      }

       public  signal  Document? create_document(Document d);
    }


  }

}
