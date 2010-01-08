require "delegate"
require "change_manager"
require "box_support"
require "forwardable"
require "simple_change"

# Constraint to keep this ref containing same value
# as the ref at path from root
class PathRefConstraint

  include PriorityComparison
  
  def initialize(root, target, path)
    @target = target
    @root = root
    @path = path

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
  
  def __update_cache
    return true if @cache_valid
    
    # Walk through the path to find the end, and set our target
    # to the same value
    cursor = @root
    
    #FIXME do we always have to clear?
    # clear the old cache
    clear_cache
    
    # Add the root to the cache, in case it can have shallow changes
    @cache.add @root
    
    # Move cursor by steps, trying to use elements of @path as
    # first a Proc, then falling back to a method symbol
    # At each stage, cache the thing we reach
    @path.each do |step|
      
      #If we hit a nil cursor, can't continue
      if !cursor
        clear_cache
        return false
        
      # Try calling the step first
      elsif (step.respond_to?(:call))
        cursor = step.call(cursor)
        
      # Otherwise, use step as a method name
      elsif (cursor.respond_to?(step))
        cursor = cursor.send(step)  
        
      # Otherwise, can't continue
      else
        clear_cache
        return false
      end
      @cache.add cursor
    end
    
    # Get rid of the last item in the cache, we store it separately
    @cache.remove cursor
    @cached_ref = cursor

    # We need to end on a ref with a get method
    if !cursor.respond_to?(:get)
        clear_cache
        return false
    end
    
    # Cache is now valid
    @cache_valid = true
    
    return true
  end
  
  def apply(propagate)
    
    #DEBUG
    puts "applying PathRefConstraint to #{@target.__id__}, prop? #{propagate}"

    # Note the cursor should end up on a ref, but we want to set
    # the target to the contained value, not the ref
    if __update_cache
      new_value = @cached_ref.get
      puts "Got value #{new_value} from @cached_ref #{@cached_ref.__id__}"
      if !Constraints.pretty_much_same(@target.get, new_value)
        @target.__setobj__ new_value
      end
    end

  end

  def __set_path(value)
    if __update_cache
      current_value = @cached_ref.get
      if !Constraints.pretty_much_same(value, current_value)
        @cached_ref.set value
      end
    end    
  end

  def priority
    200    
  end

end


# Stores a reference to a value
# Delegates to that value, so sending any method will pass
# through to the value itself - you may treat the Ref as being
# the contained value, like a WeakRef.
# Defines additional methods overriding those of the contained value,
# prefixed with ref_
# eql? to itself (same instance) ONLY, default hash.
# This is a Box, and so can be viewed and constrained
class PathRef < Delegator 
  
  # Create a PathRef
  # initial_value is the first Ref value, may be nil
  # klass is the class of the contents, may be nil indicating any class, not actually checked
  # change_manager is optional ChangeManager, if nil the default instance is used 
  def initialize(root, path, klass_value = nil, change_manager = nil)
    #Default to shared change manager instance
    @change_manager = change_manager || ChangeManager.instance

    super nil
    @v = nil
    @klass = klass_value
    @support = BoxSupport.new
    
    # This constraint ensures we always contain the value at the end of the path,
    # and also allows us to find the ref at the end of the path to set it when we are set
    @constraint = PathRefConstraint.new root, self, path
  end

  def klass
    @klass
  end

  # Delegate Box methods to @support
  extend Forwardable
  def_delegators :@support, *BoxSupport.delegate_methods
  
  # Methods for delegator:
  
  # Get the current value, for delegator
  def __getobj__
    # We may be about to read state from our contents, so make sure we
    # update contents if necessary
    @change_manager.before_read self
    @v
  end

  # Just set new delegate object, this will only happen from
  # our constraint applying 
  def __setobj__(v)
    @v = v
  end

  # Methods specific to single-value ref

  # Set a new value for v, this both sets the internal value,
  # AND fires events to listeners
  def set(v)
    # Just set in the path ref, this will lead to 
    # constraint setting us back, and to firing correct
    # changes etc.
    @constraint.__set_path v
  end

  # Get the value directly
  def get
    __getobj__
  end

end
