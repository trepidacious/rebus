require "simple_change"
require "change_manager"
require "weak_ref_count"
require "forwardable"
require "box_support"
require "ref_test"

class ArrayBoxConstraint
  
  def initialize(target)
    @target = target
    # register on target, so it keeps us in scope
    @target.constraint_register self
  end
  
  def propagate(changes)
    # If any contained box changes, the ref changes in a deep way
    {@target => SimpleChange.deep}
  end
  
  def apply(propagate)
    # Nothing to do, we are just propagating changes
  end
  
end

class ArrayBox

  def initialize(initial_contents = nil, klass_value = nil, change_manager = nil)
    @support = BoxSupport.new
    if initial_contents.nil?
      @core = []
    else
      @core = initial_contents.dup
    end
    @klass = klass_value
    @change_manager = change_manager || ChangeManager.instance
    @refs = WeakRefCount.new
    @constraint = ArrayBoxConstraint.new self
  end
  
  def klass
    @klass
  end

  # Delegate Box methods to @support
  extend Forwardable
  def_delegators :@support, *BoxSupport.delegate_methods

  def self.delegate_reads(*methods)
    methods.each do |method|
      module_eval <<-END_OF_CODE
        def #{method}(*args, &block)
          @change_manager.before_read self          
          @core.send(:#{method}, *args, &block)
        end
      END_OF_CODE
    end
  end

  def self.delegate_writes(*methods)
    #FIXME method needs to track around change
    methods.each do |method|
      module_eval <<-END_OF_CODE
        def #{method}(*args, &block)
          make_change {@core.send(:#{method}, *args, &block)}
        end
      END_OF_CODE
    end
  end
  
  def make_change()
    begin
      @change_manager.before_change(self)
      clear_tracking
      # FIXME is this correct? want to return whatever block returns
      return yield
    ensure
      retrack_all
      @change_manager.after_change(self,  SimpleChange.shallow)
    end
  end
  
  def clear_tracking
    @refs.each do |item|
      if (item.respond_to?(:constraint_unlisten))
        item.constraint_unlisten @constraint
      end
    end
    @refs.clear
  end
  
  def retrack_all
    @core.each {|item| track item}
  end
  
  def track(item)
    return if item.nil?
    
    # When we add for first time, also listen if possible
    if @refs.add(item) == 1
      if (item.respond_to?(:constraint_listen))
        item.constraint_listen @constraint
      end
    end
  end

  def untrack(item)
    return if item.nil?
    
    # When we remove for last time, also listen if possible
    if @refs.add(item) == 0
      if (item.respond_to?(:constraint_unlisten))
        item.constraint_unlisten @constraint
      end
    end
  end

  delegate_reads "[]", "first", "each", "each_index", "join", "empty?", "==", "<=>", "include?", "index", "last", "fetch"
  delegate_writes "[]=", "delete", "push", "replace"

  # more efficient versions of simple write methods, that don't need to trigger retrack_all

  # Replace the entry at index, with obj. Return the old entry
  def replace_at(index, obj)
    begin
      @change_manager.before_change(self)
      old_value = @core[index]
      untrack old_value
      @core[index] = obj
      track obj
      return old_value
    ensure
      @change_manager.after_change(self,  SimpleChange.shallow)
    end
  end
  
  def delete_at(index)
    begin
      @change_manager.before_change(self)
      deleted = @core.delete_at(index)
      untrack deleted
      return deleted
    ensure
      @change_manager.after_change(self,  SimpleChange.shallow)
    end
  end
  
  def insert(index, *obj)
    begin
      @change_manager.before_change(self)
      result = @core.insert(index, *obj)
      obj.each {|item| track item}
      return result
    ensure
      @change_manager.after_change(self,  SimpleChange.shallow)
    end
  end

  def push(*obj)
    begin
      @change_manager.before_change(self)
      result = @core.push(*obj)
      obj.each {|item| track item}
      return result
    ensure
      @change_manager.after_change(self,  SimpleChange.shallow)
    end
  end

  def <<(*obj)
    begin
      @change_manager.before_change(self)
      result = @core.<<(*obj)
      obj.each {|item| track item}
      return result
    ensure
      @change_manager.after_change(self,  SimpleChange.shallow)
    end
  end

  #FIXME need more efficient version of [], if possible, may be complicated
  #FIXME need more detailed list changes, giving indices etc. for simple methods

end

if __FILE__ == $0
  puts "Hi"
  
  a = ArrayBox.new
  
  print_a = lambda {puts ">>" + a.join(", ")}
  a.add_view print_a
  
  a[0] = "Bob"
  
  a[0, 3] = [ 'a', 'b', 'c' ]
  
  a.push "d"
  
  bob = Person.example
  bob.name = "Bob"
  
  puts "a.push bob"
  a.push bob
  
  puts 'bob.name = "Bob renamed"'
  bob.name = "Bob renamed"
  
  puts 'a.delete bob'
  a.delete bob
  
  puts 'bob.name = "Bob renamed again"'
  bob.name = "Bob renamed again"
  
  puts 'a.insert(0, "Z")'
  a.insert(0, "Z")
  
  puts 'a.insert(0, bob)'
  a.insert(0, bob)
  
  puts 'bob.name = "Bob yet another name"'
  bob.name = "Bob yet another name"
  
end
  