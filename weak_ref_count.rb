
# Stores a reference count to listeners, and allows executing
# a block on each listener with a positive count.
# References are by identity, so listeners are only the same
# if they are the same object, not just equal
# References are via object id, so should work as weak references

class WeakRefCount

  def initialize()
    @counts = {}
    
    # When a key is finalised, remove its id from the counts hash
    @finalize = lambda do |id|
      @counts.delete id
    end
  end
  
  def clear()
    @counts.clear
  end
  
  # Add a new reference to an item, and return its new reference
  # count - e.g. if the item has just been added for the first time,
  # this will be 1
  def add(item)
    #Increment count for the id of this object, starting from 0 if no count
    
    id = item.__id__
    count = @counts[id]
    
    # If we had no count, start from 0 and also make
    # sure we will remove the mapping if the item
    # is finalized
    # Unfortunately we may end up adding more than one
    # finaliser, but it should be fairly uncommon for
    # keys to be added and removed repeatedly
    if !count
      count = 0
      ObjectSpace.define_finalizer(item, @finalize)
    end
    
    count ||= 0
    count += 1
    @counts[id] = count
    
    return count
  end

  # Remove a reference to an item, and return its new reference
  # count - e.g. if the item has just been removed completely,
  # this will be 0. If the item was not actually present before
  # being removed, -1 will be returned
  def remove(item)
    #Decrement count for this object (0 if no count)
    id = item.__id__
    count = (@counts[id] || 0) - 1
    #Set new count, remove if it is now 0
    if (count > 0)
      @counts[id] = count
    else
      @counts.delete(id)
    end
    
    return count
  end

  # Yield each item that has a positive reference count
  def each()
    # We use delete_if to iterate the objects, and also to clear
    # any mappings for objects that have been GCed (we might as well do
    # it here, it may also get re-deleted when key is finalized)
    @counts.delete_if do |key, value|
      begin
        yield ObjectSpace._id2ref(key)
        false
      rescue RangeError
        true
      end
    end
  end

end

# Version below is strong, for debugging any problems with weak version
#class WeakRefCount
#
#  def initialize()
#    @counts = {}
#  end
#  
#  def clear()
#    @counts.clear
#  end
#  
#  def add(item)
#    #Increment count for the id of this object, starting from 0 if no count
#    count = @counts[item]
#    count ||= 0
#    @counts[item] = count + 1
#  end
#
#  def remove(item)
#    #Decrement count for this object (0 if no count)
#    count = (@counts[item] || 0) - 1
#    #Set new count, remove if it is now 0
#    if (count > 0)
#      @counts[item] = count
#    else
#      @counts.delete(item)
#    end
#  end
#
#  def each()
#    @counts.each_key do |key|
#      yield key
#    end
#  end
#
#end




if __FILE__ == $0
  l = WeakRefCount.new
  
  puts "add bob, just bob:"
  l.add(:bob)
  l.each {|x| puts x}

  puts "add bob, still just bob:"
  l.add(:bob)
  l.each {|x| puts x}

  puts "add cate, bob and cate:"
  l.add(:cate)
  l.each {|x| puts x}

  puts "remove bob, still bob and cate:"
  l.remove(:bob)
  l.each {|x| puts x}

  puts "remove bob, bob's gone, just cate:"
  l.remove(:bob)
  l.each {|x| puts x}

  puts "remove cate, no one left:"
  l.remove(:cate)
  l.each {|x| puts x}

end
