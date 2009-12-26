require 'ref.rb'
require 'ref_accessor.rb'
require "node.rb"

class Person < Node
  
  ref_accessor :name, :nick, :address, :friends, :age
  
  def initialize()
    super 
    @name = add_box
    @nick = add_box
    @address = add_box
    @friends = add_box
    @age = add_box
  end
  
  def say_hi
    puts "Hi! I'm #{name}"
  end
  
  def to_s
    "#{name} (#{nick}), age #{age}, at #{address}, #{friends}"
  end
  
end

class Address < Node
  
  ref_accessor :house, :street, :town

  def initialize()
    super
    @house = add_box
    @street = add_box
    @town = add_box
  end
  
  def to_s
    "#{house}, #{street}, #{town}"
  end

end

if __FILE__ == $0

  bob = Person.new

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

  puts Path.follow(bob, :address, :house)

  puts Path.follow(bob, lambda {|x| x.address}, :house)

  puts Path.follow(bob, lambda {|x| x.friends[0]}, :name)

  puts Path.follow(bob, lambda {|x| x.friends[1]}, :name)

end