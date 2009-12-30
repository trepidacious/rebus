require 'ref.rb'
require 'ref_accessor.rb'
require "node.rb"
require 'gtk2'

class Person < Node
  
  ref_accessor [:name,  "String"], [:nick, "String"], [:address, "Address"], [:friends, "Array"], [:age, "Fixnum"], [:zombie, "TrueClass"], [:enlightenment, "Float"], [:color, "Gdk::Color"]
  
  def initialize()
    super 
    initialize_refs
  end
  
  def say_hi
    puts "Hi! I'm #{name}"
  end
  
  def self.example
    example = Person.new
    example.name = "Name"
    example.nick = "Nick"
    example.address = Address.example
    example.friends = [Person.new]
    example.age = 0
    example.zombie = false
    example.enlightenment = 0.5
    example.color = Gdk::Color.new(10000, 10000, 40000)
    example
  end
  
end

class Address < Node
  
  ref_accessor :house, :street, :town

  def initialize()
    super
    initialize_refs
  end
  
  def self.example
    example = Address.new
    example.house = "House"
    example.street = "Street"
    example.town = "Town"
    example
  end

end

if __FILE__ == $0

  bob = Person.new

  p bob.refs

  print_bob = lambda {puts "View sees #{bob}"}
  bob.add_view print_bob 
  
  bob.name="Bob"
  puts bob.name
  bob.say_hi

  bobref = Ref.new(bob)
  puts "name from ref #{bobref.name}"
  bobref.say_hi

  
  alice = Person.new
  alice.name = "Alice"

  cate = Person.new
  cate.name = "Cate"

  bob.friends = [alice, cate]
  
  bob_address = Address.new
  bob_address.house = "bob's house"
  bob_address.street = "bob's street"
  bob_address.town = "bobville"

  bob.address = bob_address

  puts bob.address.house

end