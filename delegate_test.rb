require "delegate"

class D < Delegator
  def initialize
    @ref_d
    super(nil)
  end
  
  def __getobj__
    @ref_d
  end
  
  def __setobj__(delegate)
    @ref_d = delegate
  end
  
  def does_this_stay?
    true
  end
end

class A
  def a 
    puts "a"
  end
end  

class B
  def b
    puts "b"
  end
end

class C < B
  def c
    puts "c"
  end
end

if __FILE__ == $0
  a = A.new
  b = B.new
  c = C.new
  d = D.new
  
  d.__setobj__(a)
  d.a
  puts d.does_this_stay?
  
  d.__setobj__(b)
  d.b
  puts d.does_this_stay?
  
  d.__setobj__(c)
  d.b
  d.c
  puts d.does_this_stay?
  
end