require 'ref_test'
require 'ref'
require 'gtk2'
#require 'ref_string_view'
#require 'ref_number_view'
#require 'ref_boolean_view'
#require 'ref_color_view'
require 'ref_node_view'
require 'views'

if __FILE__ == $0

#  bob = Person.new
#  bob.name = "Bob's Name"
#  bob.nick = "Old Bobby McBobBob"
#  bob.age = 30
#  bob.zombie = false
#  bob.enlightenment = 0.5
#  bob.color = Gdk::Color.new(10000, 10000, 40000)

  alice = Person.example
  alice.name = "Alice"
  
  print_alice = lambda do
    puts "ALICE Change: #{alice}"
  end
  
  print_alice.call
  alice.add_view print_alice


  bob = Person.example
  bob.name = "Bob"
  
  print_bob = lambda do
    puts "BOB Change: #{bob}"
  end
  
  print_bob.call
  bob.add_view print_bob
  
#  name_view = Views.ref_view bob.name
#  nick_view = Views.ref_view bob.nick
#  age_view = Views.ref_view bob.age
#  zombie_view = Views.ref_view bob.zombie, "Zombify?"
#  enlightenment_view = Views.ref_view bob.enlightenment, 0, 1, 0.1, :scale
#  color_view = Views.ref_view bob.color

#  vbox = Gtk::VBox.new(false, 5)
#  vbox.pack_start_defaults(name_view.widget)
#  vbox.pack_start_defaults(nick_view.widget)
#  vbox.pack_start_defaults(age_view.widget)
#  vbox.pack_start_defaults(zombie_view.widget)
#  vbox.pack_start_defaults(enlightenment_view.widget)
#  vbox.pack_start_defaults(color_view.widget)

#  window.add(vbox)

  person_ref = Ref.new bob
  
#  path_ref = Ref.new(nil, bob.name.klass)
#  Constraints.path(person_ref, path_ref, :name)
#  
#  puts "person_ref is #{person_ref}"
#  puts "path_ref is #{path_ref}"
  
  node_view = RefNodeView.new person_ref, Person.example
  
  window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
  window.set_title  "Bob!"
  window.border_width = 10
  window.signal_connect('delete_event') { Gtk.main_quit }

  box = Gtk::VBox.new(false, 6)
  
  box.pack_start(Gtk::Label.new("Edited Person:"), false, true, 0)
  
  box.pack_start(node_view.widget, false, true, 0)

  alice_button = Gtk::Button.new("Alice")
  alice_button.signal_connect(:clicked) {person_ref.set alice}

  bob_button = Gtk::Button.new("Bob")
  bob_button.signal_connect(:clicked) {person_ref.set bob}

  box.pack_start(Gtk::Label.new("Change Person:"), false, true, 0)

  box.pack_start(alice_button, false, true, 0)
  box.pack_start(bob_button, false, true, 0)

  window.add(box)

  window.show_all
  Gtk.main
  
end