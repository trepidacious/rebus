class SimpleChange
  
  attr_reader :shallow
  
  def initialize(shallow)
    @shallow = shallow
  end

  def self.shallow()
    @@shallow ||= SimpleChange.new(true)
    return @@shallow
  end

  def self.deep()
    @@deep ||= SimpleChange.new(false)
    return @@deep
  end
  
  def instance(shallow_instance)
    if (shallow_instance)
      return shallow()
    else
      return deep()
    end
  end

  def extend(existing)
    new_shallow = existing.shallow || @shallow
    if new_shallow != @shallow
      return instance(new_shallow) 
    else
      return nil
    end
  end

end