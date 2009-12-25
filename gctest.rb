require "weakref"

class DoNothing
  def or_maybe_something(x)
    puts "Called or_maybe_something"
  end
end

def load_file()
  file = File.new("/home/shingoki/bigfile", "r")
  s = ""
  while (line = file.gets)
    s += line
  end
  file.close
  s
end

if __FILE__ == $0
#  foo = Object.new
#  p foo.to_s      # original's class
#  
#  dn = DoNothing.new
#  
#  id = foo.__id__
#  puts "foo id is #{id}"
#
#  #Uncomment this line to make gc stop doing anything!
#  #dn.or_maybe_something(foo)
#  
#  foo = WeakRef.new(foo)
#  p foo.to_s      # should be same class
#  ObjectSpace.garbage_collect
#  ObjectSpace.garbage_collect
#  #p foo.to_s      # should raise exception (recycled)
#  
#  #Make some big stuff
#  a=File.read("/home/shingoki/bigfile")
#  b=File.read("/home/shingoki/bigfile")
#  c=File.read("/home/shingoki/bigfile")
#  d=File.read("/home/shingoki/bigfile")
#
#  ObjectSpace.garbage_collect
#  ObjectSpace.garbage_collect
#
#  begin
#    puts "Found foo from id: #{ObjectSpace._id2ref id}"
#  rescue RangeError
#    puts "Tried find foo from id, had been recycled"
#  end
#  
#  puts "Looking for foo id"
#  ObjectSpace.each_object {|x| puts "FOUND #{id}" if id == x.__id__}

end