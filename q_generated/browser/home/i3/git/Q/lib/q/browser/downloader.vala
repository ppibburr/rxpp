namespace Q {
  namespace Browser {

    public class Downloader {
private Gee.ArrayList<WebKit.Download> _downloads;
      private WebKit.WebContext _context;
      public WebKit.WebContext context {get { return this._context;}}

            public  WebKit.Download[] downloads {
          owned get {

            return (this._downloads.to_array());

          }


        }


      public Downloader (WebKit.WebContext c) {
        this._downloads = new Gee.ArrayList<WebKit.Download>();
        this._context = c;
        c.download_started.connect((d) => {
          manage(d);

        });

      }

       public   virtual  void manage(WebKit.Download d) {
        this._downloads.add(d);
        add(d);
        d.received_data.connect(() => {
          status(d, d.estimated_progress);

        });
        d.finished.connect(() => {
          complete(d);

        });
        d.failed.connect(() => {
          fail(d);

        });
        d.decide_destination.connect((s) => {
          save_file(d, s);
          return (false);

        });

      }

       public   virtual  void download(string u) {
        manage(this.context.download_uri(u));

      }

       public  signal  void add(WebKit.Download d);

       public  signal  void fail(WebKit.Download d);

       public  signal  void complete(WebKit.Download d);

       public  signal  void status(WebKit.Download d, double p);

       public  signal  void save_file(WebKit.Download d, string name);
    }


  }

}
