require 'ref_test'
require 'ref'
require 'gtk2'
require 'ref_text_view'
require 'ref_spinner_view'

if __FILE__ == $0

  bob = Person.new
  bob.name = "Bob's Name"
  bob.nick = "Old Bobby McBobBob"
  bob.age = 30
  
  print_bob = lambda {puts "Change: #{bob}"}
  bob.add_view print_bob
  
  name_view = RefTextView.new bob.name
  nick_view = RefTextView.new bob.nick
  age_view = RefSpinnerView.new bob.age
  
  window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
  window.set_title  "Bob!"
  window.border_width = 10
  window.signal_connect('delete_event') { Gtk.main_quit }
  
  # Note "getlogin" is Unix/Linux feature if you do not have it,
  # you should replace the [getlogin] below with something reasonable.
  #
#  question  = Gtk::Label.new("What is %s's password?" % [getlogin])
#  entry_label = Gtk::Label.new("Password:")
#  
#  pass = Gtk::Entry.new
#  pass.visibility = false
  
  # The following property takes integer value not string character
  # pass.invisible_char = 42           ### for instance 42=asterisk
  
#  hbox = Gtk::HBox.new(false, 5)
#  hbox.pack_start_defaults(entry_label)
#  hbox.pack_start_defaults(pass)

  vbox = Gtk::VBox.new(false, 5)
  vbox.pack_start_defaults(name_view.widget)
  vbox.pack_start_defaults(nick_view.widget)
  vbox.pack_start_defaults(age_view.widget)
  
  window.add(vbox)
  window.show_all
  Gtk.main
  
end