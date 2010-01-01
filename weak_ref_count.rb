
# Stores a reference count to listeners, and allows executing
# a block on each listener with a positive count.
# References are by identity, so listeners are only the same
# if they are the same object, not just equal
# References are via object id, so should work as weak references

class WeakRefCount

  def initialize()
    @counts = {}
  end
  
  def clear()
    @counts.clear
  end
  
  def add(item)
    #Increment count for the id of this object, starting from 0 if no count
    id = item.__id__
    count = @counts[id]
    count ||= 0
    @counts[id] = count + 1
  end

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
  end

  def each()
    #We use delete_if to iterate the objects, and also to clear
    #any mappings for objects that have been GCed
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
#    #We use delete_if to iterate the objects, and also to clear
#    #any mappings for objects that have been GCed
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
