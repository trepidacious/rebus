require 'gtk2'

if __FILE__ == $0

  window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
  window.set_title  "Spin Buttons"
  window.border_width = 10
  window.signal_connect('delete_event') { Gtk.main_quit }
  window.set_size_request(250, -1)
  
                             # min, max,  step
  integer = Gtk::SpinButton.new(0.0, 10.0, 1.0)
  float   = Gtk::SpinButton.new(0.0, 1.0,  0.1)
  
  vbox = Gtk::VBox.new(false, 5)
  vbox.pack_start(integer, false, true, 0)
  vbox.pack_start(float,   false, true, 0)
  
  window.add(vbox)
  window.show_all
  Gtk.main
  
end