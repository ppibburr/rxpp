namespace Q {

  namespace UI {


    public class InfoBar : Gtk.InfoBar {
construct {
        Gtk.Revealer revealer = (Gtk.Revealer)get_template_child(typeof(Gtk.InfoBar), "revealer");

        if ((revealer != null)) {
          revealer.transition_type = Gtk.RevealerTransitionType.NONE;
          revealer.set_transition_duration(0);

        };

      }

      public InfoBar.with_buttons (Value?[] argv = null) {
        Object();
        int i; i = 0;
        while (argv[i] != null) {
          add_button((string)argv[i], (int)argv[i + 1]);
          i += 2;

        };

      }
    }


  }

}
