require "gtk2"
require "ref_test"

class SimpleConstraint
  
  # Make a constraint, processing sources via a calculation, to
  # give a value for the target
  def initialize(sources, calc, target)
    @target = target
    
    # register on target, so it keeps us in scope
    @target.constraint_register self
    @calc = calc
    @sources = sources
    if (sources.respond_to?(:each_value))
      sources.each_value do |source|
        source.constraint_listen self
      end
    else
      sources.each do |source|
        source.constraint_listen self
      end
    end
    
    # set targets to start
    apply true
  end
  
  def propagate(changes)
    # We may put a new instance into target
    {@target => SimpleChange.shallow}
  end
  
  def apply(propagate)
    @target.ref_constrain @calc.call(@sources), propagate
  end
  
end

class UnhelpfulConstraint
  
  # Make a constraint, processing sources via a calculation, to
  # give a value for the target
  def initialize(sources, calc, target)
    @target = target
    
    # register on target, so it keeps us in scope
    @target.constraint_register self
    @calc = calc
    @sources = sources
    if (sources.respond_to?(:each_value))
      sources.each_value do |source|
        source.constraint_listen self
      end
    else
      sources.each do |source|
        source.constraint_listen self
      end
    end  
    # set targets to start
    apply true   
  end
  
  def propagate(changes)
    # We just say anything may change
    {:unknown => SimpleChange.shallow}
  end
  
  def apply(propagate)
      # We can read state here, so we can now work out what we actually change
      
      # Read state just to show we can
      @target.get
      @target.ref_constrain @calc.call(@sources), propagate
  end
  
end

class ForwardPathConstraint

  def initialize(from, target, *to)
    @target = target
    @root = from
    @path = to

    # Keep weak references to the stages of the path
    @cache = WeakRefCount.new
    @cache_valid = false
    @cached_ref = nil
    
    # Listen to the root
    @root.constraint_listen self

    # Register on target, so it keeps us in scope
    @target.constraint_register self
    
    # Start out up to date
    apply true
  end

  def propagate(changes)
    # As an optimisation, we want to see whether the changes 
    # could have left us needing to apply, that is, if the
    # path could lead us to a different value
    
    # If we don't have a valid cache, then we can't check, so just say
    # we may change
    if (!@cache_valid)
      return {@target => SimpleChange.shallow}
    end
    
    # If we DO have a cache, then we will change if any of the cached refs
    # have a shallow change
    path_shallow_change = false
    @cache.each do |ref|
      change = changes[ref]
      if change
        if change.shallow
          path_shallow_change = true
        end
      end
    end
    
    # If we've had a shallow change, cache is no longer valid, and we
    # may need to apply
    if path_shallow_change
      clear_cache
      return {@target => SimpleChange.shallow}
    end
    
    # Finally, if the actual ref the path leads to has had a change, then
    # the cache is still valid, and we have the same type of change
    final_change = changes[@cached_ref]
    if (final_change)
      return {@target => final_change}
    end
    
    #Otherwise, we don't have a change
  end
  
  def clear_cache
    @cache.clear
    @cached_ref = nil
    @cache_valid = false
  end
  
  def apply(propagate)
    # Walk through the path to find the end, and set our target
    # to the same value
    cursor = @root
    
    #FIXME do we always have to clear?
    # clear the old cache
    clear_cache
    
    # Move cursor by steps, trying to use elements of @path as
    # first a Proc, then falling back to a method symbol
    # At each stage, cache the thing we reach
    @path.each do |step|
      
      #If we hit a null cursor, can't continue
      if (cursor == nil)
        clear_cache
        return
        
      # Try calling the step first
      elsif (step.respond_to?(:call))
        cursor = step.call(cursor)
        
      # Otherwise, use step as a method name
      elsif (cursor.respond_to?(step))
        cursor = cursor.send(step)  
        
      # Otherwise, can't continue
      else
        clear_cache
        return
      end
      @cache.add cursor
    end
    
    # Get rid of the last item in the cache, we store it separately
    @cache.remove cursor
    @cached_ref = cursor

    # We need to end on a ref with a get method
    if !cursor.respond_to?(:get)
        clear_cache
        return      
    end
    
    # Note the cursor should end up on a ref, but we want to set
    # the target to the contained value, not the ref
    @target.ref_constrain cursor.get, propagate
    
    # Cache is now valid
    @cache_valid = true

  end
  
end

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

  ForwardPathConstraint.new bob, bob_house, :address, :house
  
  print_bobs_house = lambda {puts "Bob's house is now #{bob_house}"}
  
  print_bobs_house.call
  
  bob_house.add_view print_bobs_house
  
  bob_address.house = "NewBobHouse"

  bob_new_address = Address.new
  bob_new_address.house = "EvenNewerBobHouse"
  puts "Setting new address"
  
  bob.address = bob_new_address

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
  SimpleConstraint.new([x, y], lambda {x + y}, a)

  puts "Constrain b = y + z"
  SimpleConstraint.new([y, z], lambda {y + z}, b)

  puts "Constrain c = a + b"
  UnhelpfulConstraint.new([a, b], lambda {a + b}, c)
  
  puts "x = 21"
  x.set 21

  puts "y = 30"
  y.set 30
  
  puts "z = 5"
  z.set 5

end