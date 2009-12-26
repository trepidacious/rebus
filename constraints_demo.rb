require "ref_test"
require "constraints"

if __FILE__ == $0

#  foo = Object.new
#  puts "foo id #{foo.__id__}"
#  puts "foo hash #{foo.hash}"
#  
#  foo_ref = Ref.new(foo)
#  puts "foo_ref id #{foo_ref.__id__}"
#  puts "foo_ref ref_id #{foo_ref.ref_id}"
#  puts "foo_ref hash #{foo_ref.hash}"
#
#  puts "foo.eql? foo_ref #{foo.eql? foo_ref}"
#  puts "foo==foo_ref #{foo==foo_ref}"
#  puts "foo.equal? foo_ref #{foo.equal? foo_ref}"

  bob = Person.new
  bob.name = "Bob"
  puts bob

  print_bob = lambda {puts bob}

  bob.add_view print_bob
  
  bob.age = 20

  bob_address = Address.new

  bob.address = bob_address

  puts "Changing address"
  bob_address.house = "BobHouse"
  bob_address.street = "BobStreet"
  bob_address.town = "BobTown"

  bob_house = Ref.new

  Constraints.path bob, bob_house, :address, :house
  
  print_bobs_house = lambda {puts "Bob's house is now #{bob_house}"}
  
  print_bobs_house.call
  
  bob_house.add_view print_bobs_house
  
  bob_address.house = "NewBobHouse"

  bob_new_address = Address.new
  bob_new_address.house = "EvenNewerBobHouse"
  puts "Setting new address"
  
  bob.address = bob_new_address

  puts "Setting bob's house from path ref"
  bob_house.set "Set House From Path"

  puts "Bob is now #{bob}, should have seen change on view as well"

  x = Ref.new(10)
  y = Ref.new(20)
  z = Ref.new(20)

  a = Ref.new
  b = Ref.new
  c = Ref.new

  print = lambda {puts "x #{x}, y #{y}, z #{z}, a #{a} (x+y #{x+y}), b #{b} (y+z #{y+z}), c #{c} (x+2y+z #{x + 2*y + z})"}

  # Listen to each ref, and print all refs when we see change
  [x, y, z, a, b, c].each {|e| e.add_view print}

  puts "Initial state"
  print.call

  puts "Constrain a = x + y"
  Constraints.simple [x, y], lambda {x + y}, a

  puts "Constrain b = y + z"
  Constraints.simple [y, z], lambda {y + z}, b

  puts "Constrain c = a + b"
  Constraints.simple [a, b], lambda {a + b}, c
  
  puts "x = 21"
  x.set 21

  puts "y = 30"
  y.set 30
  
  puts "z = 5"
  z.set 5

end