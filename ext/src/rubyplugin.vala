using Xfce;
extern void load_rb(string data);
public class RubyPlugin : Xfce.PanelPlugin {
  public static RubyPlugin plugin;
	public override void @construct () {
	  plugin=this;
	
	  load_rb("{}");
	
		save.connect (() => { message ("save yourself"); });
		free_data.connect (() => { message ("free yourself"); });
		size_changed.connect (() => { message ("panel size changed"); return false; });
	}
	
	public static Gtk.EventBox @default() {
	  return (Gtk.EventBox)plugin;
	}
}

[ModuleInit]
public Type xfce_panel_module_init (TypeModule module) {
	return typeof (RubyPlugin);
}

