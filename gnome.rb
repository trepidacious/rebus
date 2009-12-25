require 'gtk2'

def font_changed(f_btt, label)
  font = f_btt.font_name
  desc = Pango::FontDescription.new(font)
  label.text = "Font: %s" % [desc]
  label.modify_font(desc)
end

window = Gtk::Window.new
window.border_width = 10
window.set_size_request(200, -1)
window.title = "Font Button"

window.signal_connect('delete_event') { false }
window.signal_connect('destroy') { Gtk.main_quit }

label = Gtk::Label.new("Look at the font")
initial_font = Pango::FontDescription.new("Sans Bold 12")
label.modify_font(initial_font)

button = Gtk::FontButton.new(initial_font)
button.title = "Choose a Font"

button.signal_connect('font_set') { |w| font_changed(w, label) }

vbox = Gtk::VBox.new(false, 5)
vbox.pack_start_defaults(button)
vbox.pack_start_defaults(label)

window.add(vbox)
window.show_all
Gtk.main