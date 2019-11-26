#!/usr/bin/env sh
sudo cp libxfce4/typelib/*typelib /usr/lib/girepository-1.0/
sudo cp libxfce4/vapi/*.vapi /usr/share/vala/vapi/
/usr/bin/env ruby <<-EOR
rbflgs = %x[pkg-config --cflags --libs ruby].strip.split(" ").join(" -X ")
puts cmd="valac ext/src/rubyplugin.vala --pkg libxfce4panel-2.0 -o librubyplugin.so --shared-library rubyplugin --library rubyplugin -X -fPIC -X -shared -X ext/src/rbld.c -X #{rbflgs}"
system cmd
EOR
