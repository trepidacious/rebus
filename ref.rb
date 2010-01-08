require "delegate"
require "change_manager"
require "box_support"
require "forwardable"
require "simple_change"

class RefConstraint
  
  def initialize(target, value=nil)
    @target = target
    # register on target, so it keeps us in scope
    @target.constraint_register self
    
    @value = value
    if @value
      if (@value.respond_to?(:constraint_listen))
        @value.constraint_listen self
      end
    end
      
  end
  
  def propagate(changes)
    # If any contained box changes, the ref changes in a deep way
    {@target => SimpleChange.deep}
  end
  
  def apply(propagate)
    # Nothing to do, we are just propagating changes
  end
  
  def change_value_to(value)
    if @value
      if (@value.respond_to?(:constraint_unlisten))
        @value.constraint_unlisten self
      end
    end
    @value = value
    if @value
      if (@value.respond_to?(:constraint_listen))
        @value.constraint_listen self
      end
    end    
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
class Ref < Delegator 
  
  # Create a Ref
  # initial_value is the first Ref value, may be nil
  # klass is the class of the contents, may be nil indicating any class, not actually checked
  # change_manager is optional ChangeManager, if nil the default instance is used 
  def initialize(initial_value = nil, klass_value = nil, change_manager = nil)
    super initial_value
    @v = initial_value
    @klass = klass_value
    @support = BoxSupport.new
    #Default to shared change manager instance
    @change_manager = change_manager || ChangeManager.instance
    
    @constraint = RefConstraint.new self, initial_value
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

  # Just set the new value for v, no events
  def __setobj__(v)
    @v = v
    @constraint.change_value_to @v
  end

  # Methods specific to single-value ref

  # Set a new value for v, this both sets the internal value,
  # AND fires events to listeners
  def set(v)
    @change_manager.before_change(self)
    __setobj__(v)
    @change_manager.after_change(self, SimpleChange.shallow)
  end
  
  # Set a new value for v from a constraint
  def ref_constrain(v, propagate)
    if propagate
      set(v)
    else
      __setobj__(v)
    end
  end

  # Get the value directly
  def get
    __getobj__
  end

end
