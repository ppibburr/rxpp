namespace Q {
  namespace UI {

    public class Stock {
public const string OPEN = "gtk-open";
      public const string CLOSE = "gtk-close";
      public const string SAVE = "gtk-save";
      public const string SAVE_AS = "gtk-save-as";
      public const string EDIT = "gtk-edit";
      public const string FILE = "gtk-file";
      public const string NEW = "gtk-new";
      public const string QUIT = "gtk-quit";
      public const string PREFERENCES = "gtk-preferences";
      public const string INFO = "gtk-dialog-info";
      public const string EXECUTE = "gtk-execute";
      public const string GO_FORWARD = "gtk-go-forward";
      public const string GO_BACK = "gtk-go-back";
      public const string REFRESH = "gtk-refresh";
    }


    public class ToolButton : Gtk.ToolButton {
public ToolButton.from_stock (string item) {
        Object();
        this.icon_name = item;

      }
    }


    public class Button : Gtk.Button {
public Button.from_stock (string item, Gtk.ReliefStyle? relief = null) {
        Object();
        this.image = new Gtk.Image.from_icon_name(item, Gtk.IconSize.BUTTON);
        if (relief != null) {
          this.relief = relief;
        }


      }
    }


  }

}
