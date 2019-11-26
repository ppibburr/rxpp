namespace Q {
  namespace UI {

    public class ApplicationWindow : Gtk.ApplicationWindow {
public static int count = 0;

            public  Application application {
          get {
            return ((Application)((Gtk.ApplicationWindow)this).application);

          }

          set {
            ((Gtk.ApplicationWindow)this).application = value;

          }


        }


      public ApplicationWindow (Application a) {
        Object(application: a);
        delete_event.connect(() => {
          count = count - 1;
          if (count <= 0 && application.quit_on_last_window_exit) {
            application.quit();
          }

          return (false);

        });

      }
    }


  }

}
