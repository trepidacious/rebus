
# Simple map from objects to values, where the key is not
# used directly - its __id__ is used instead.
# This means that when looking up a value, you get the
# value for that exact instance, NOT for some equal key
# This is useful for listeners, changes on data, etc. 
class IdentityMap
  
  def initialize
    @hash = {}
  end
  
  def [](key)
    @hash[key.__id__]
  end

  def []=(key, value)
    @hash[key.__id__]=value
  end

  def each_key
    @hash.each_key do |id|
      yield ObjectSpace._id2ref id
    end
  end

end

if __FILE__ == $0
  
  i = IdentityMap.new
  i[:a] = "a"
  puts i[:a]
  
  
end
  
  