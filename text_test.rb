require 'ref_test'
require 'ref'
require 'gtk2'
require 'ref_string_view'
require 'ref_number_view'
require 'ref_boolean_view'
require 'ref_color_view'

if __FILE__ == $0

  bob = Person.new
  bob.name = "Bob's Name"
  bob.nick = "Old Bobby McBobBob"
  bob.age = 30
  bob.zombie = false
  bob.enlightenment = 0.5
  bob.color = Gdk::Color.new(65535, 6000, 6000)
  
  print_bob = lambda {puts "Change: #{bob}"}
  print_bob.call
  bob.add_view print_bob
  
  name_view = RefStringView.new bob.name
  nick_view = RefStringView.new bob.nick
  age_view = RefNumberView.new bob.age
  zombie_view = RefBooleanView.new bob.zombie, "Zombify?"
  enlightenment_view = RefNumberView.new bob.enlightenment, 0, 1, 0.1, :scale
  color_view = RefColorView.new bob.color
  
  window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
  window.set_title  "Bob!"
  window.border_width = 10
  window.signal_connect('delete_event') { Gtk.main_quit }

  vbox = Gtk::VBox.new(false, 5)
  vbox.pack_start_defaults(name_view.widget)
  vbox.pack_start_defaults(nick_view.widget)
  vbox.pack_start_defaults(age_view.widget)
  vbox.pack_start_defaults(zombie_view.widget)
  vbox.pack_start_defaults(enlightenment_view.widget)
  vbox.pack_start_defaults(color_view.widget)
  
  window.add(vbox)
  window.show_all
  Gtk.main
  
end