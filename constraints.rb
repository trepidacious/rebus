require 'priority_comparison'

# Factory for constraints
class Constraints
  def self.simple(sources, calc, target)
    SimpleConstraint.new sources, calc, target
  end
  
#  def self.forward_path(from, target, *to)
#    ForwardPathConstraint.new(from, target, *to)
#  end
#
#  def self.reverse_path(root, source, *path)
#    ReversePathConstraint.new(root, source, *path)
#  end
#
#  def self.path(from, target, *path)
#    # Apply forward path first, since we want the target to be updated
#    # to the root->path value first. That is, we consider the initial
#    # state of the root->path value to be the important state, and the
#    # initial target state is overwritten.
#    ForwardPathConstraint.new(from, target, *path)
#    ReversePathConstraint.new(from, target, *path)
#  end

  def self.range(target, range)
    RangeConstraint.new(target, range)
  end

  # FIXME should refs just already ignore changes to an equal? value?
  def self.pretty_much_same(a, b)
    if !a
      return !b
    else
      return a.equal? b
    end
  end

end

# Simple constraint, constrains a number to lie in a given
# range
class RangeConstraint
  
  include PriorityComparison
  
  # Make a constraint, processing sources via a calculation, to
  # give a value for the target
  def initialize(target, range)
    @target = target
    @range = range
    
    # register on target, so it keeps us in scope
    @target.constraint_register self

    # listen to target, so we can override edits
    @target.constraint_listen self
    
    # set targets to start
    apply true
  end
  
  def propagate(changes)
    # We may put a new instance into target, if it is out of range
    {@target => SimpleChange.shallow}
  end
  
  def apply(propagate)
    
    #DEBUG
    # puts "applying range to #{@target.__id__}, prop? #{propagate}"
    
    value = @target.get
    if (value) 
      if (value > @range.last)
        value = @range.last
        @target.ref_constrain value, propagate
      elsif (value < @range.first)
        value = @range.first
        @target.ref_constrain value, propagate
      end
    else
      value = @range.first
    end
  end
  
  def priority
    100    
  end

end

# Simple constraint, uses a procedure on a list or map of
# sources to produce a value that is set into a target
class SimpleConstraint

  include PriorityComparison
  
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

  def priority
    90    
  end

end
#
## Constraint that sets a target to a value looked up by
## starting from a root object "from", and then progressing
## step by step to a final Ref The value of this Ref is
## set into the target Ref
#class ForwardPathConstraint
#
#  include PriorityComparison
#  
#  def initialize(from, target, *to)
#    @target = target
#    @root = from
#    @path = to
#
#    # Keep weak references to the stages of the path
#    @cache = WeakRefCount.new
#    @cache_valid = false
#    @cached_ref = nil
#    
#    # Listen to the root
#    @root.constraint_listen self
#
#    # Register on target, so it keeps us in scope
#    @target.constraint_register self
#    
#    # Start out up to date
#    apply true
#  end
#
#  def propagate(changes)
#    # As an optimisation, we want to see whether the changes 
#    # could have left us needing to apply, that is, if the
#    # path could lead us to a different value
#    
#    # If we don't have a valid cache, then we can't check, so just say
#    # we may change
#    if (!@cache_valid)
#      return {@target => SimpleChange.shallow}
#    end
#    
#    # If we DO have a cache, then we will change if any of the cached refs
#    # have a shallow change
#    path_shallow_change = false
#    @cache.each do |ref|
#      change = changes[ref]
#      if change
#        if change.shallow
#          path_shallow_change = true
#        end
#      end
#    end
#    
#    # If we've had a shallow change, cache is no longer valid, and we
#    # may need to apply
#    if path_shallow_change
#      clear_cache
#      return {@target => SimpleChange.shallow}
#    end
#    
#    # Finally, if the actual ref the path leads to has had a change, then
#    # the cache is still valid, and we have the same type of change
#    final_change = changes[@cached_ref]
#    if (final_change)
#      return {@target => final_change}
#    end
#    
#    #Otherwise, we don't have a change
#  end
#  
#  def clear_cache
#    @cache.clear
#    @cached_ref = nil
#    @cache_valid = false
#  end
#  
#  def apply(propagate)
#    
#    #DEBUG
#    puts "applying forward path to #{@target.__id__}, prop? #{propagate}"
#
#    # Walk through the path to find the end, and set our target
#    # to the same value
#    cursor = @root
#    
#    #FIXME do we always have to clear?
#    # clear the old cache
#    clear_cache
#    
#    # Add the root to the cache, in case it can have shallow changes
#    @cache.add @root
#    
#    # Move cursor by steps, trying to use elements of @path as
#    # first a Proc, then falling back to a method symbol
#    # At each stage, cache the thing we reach
#    @path.each do |step|
#      
#      #If we hit a nil cursor, can't continue
#      if !cursor
#        clear_cache
#        return
#        
#      # Try calling the step first
#      elsif (step.respond_to?(:call))
#        cursor = step.call(cursor)
#        
#      # Otherwise, use step as a method name
#      elsif (cursor.respond_to?(step))
#        cursor = cursor.send(step)  
#        
#      # Otherwise, can't continue
#      else
#        clear_cache
#        return
#      end
#      @cache.add cursor
#    end
#    
#    # Get rid of the last item in the cache, we store it separately
#    @cache.remove cursor
#    @cached_ref = cursor
#
#    # We need to end on a ref with a get method
#    if !cursor.respond_to?(:get)
#        clear_cache
#        return      
#    end
#    
#    # Note the cursor should end up on a ref, but we want to set
#    # the target to the contained value, not the ref
#    new_value = cursor.get
#    if !Constraints.pretty_much_same(@target.get, new_value)
#      @target.ref_constrain new_value, propagate
#    end
#    
#    # Cache is now valid
#    @cache_valid = true
#
#  end
#
#  def priority
#    200    
#  end
#
#end
#
## Constraint that sets a target looked up by
## starting from a root object "from", and then progressing
## step by step to a final Ref. The value of this Ref is
## set from the source Ref
#class ReversePathConstraint
#
#  include PriorityComparison
#  
#  def initialize(root, source, *path)
#    @root = root
#    @source = source
#    @path = path
#
#    # Keep weak references to the stages of the path
#    @cache = WeakRefCount.new
#    @cache_valid = false
#    @cached_ref = nil
#    
#    # Listen to the root, and the source
#    @root.constraint_listen self
#    @source.constraint_listen self
#
#    # FIXME do we need to register on anything else?
#    # Register on root, so it keeps us in scope
#    @root.constraint_register self
#    
#    # Start out up to date
#    apply true
#  end
#
#  def propagate(changes)
#    # As an optimisation, we want to see whether the changes 
#    # could have left us needing to apply, that is, if the
#    # path could lead us to a different value
#
#    # If we have no cache, we should say we will make a change, but we don't know what
#    # to. It will be shallow.
#    if !@cache_valid
#      return {:unknown => SimpleChange.shallow}
#    end
#
#    # First, we work out whether our cache is still good
#    @cache.each do |ref|
#      change = changes[ref]
#      # If we've had a shallow change, cache is no longer valid,
#      # and we should say we will make a change, but we don't know what
#      # to. It will be shallow.
#      if change
#        if change.shallow
#          clear_cache
#          return {:unknown => SimpleChange.shallow}
#        end
#      end
#    end
#    
#    # If the actual ref the path leads to has had a change, 
#    # then we will need to apply to undo the change
#    # The cache is still valid though, and we know which
#    # ref we will be setting
#    final_change = changes[@cached_ref]
#    if (final_change)
#      return {@cached_ref => SimpleChange.shallow}
#    end
#    
#    # Finally, if we have had a shallow change to the source ref, we will
#    # Need to apply to copy the new value across, but the cache is valid,
#    # so we know what we are setting
#    source_change = changes[@source]
#    if (source_change)
#      if source_change.shallow
#        return {@cached_ref => SimpleChange.shallow}
#      end
#    end
#    
#    #Otherwise, we don't have a change
#  end
#  
#  def clear_cache
#    @cache.clear
#    @cached_ref = nil
#    @cache_valid = false
#  end
#  
#  def apply(propagate)
#    
#
#    # Walk through the path to find the end, and set our target
#    # to the same value
#    cursor = @root
#    
#    #FIXME do we always have to clear?
#    # clear the old cache
#    clear_cache
#    
#    # Add the root to the cache, in case it can have shallow changes
#    @cache.add @root
#
#    # Move cursor by steps, trying to use elements of @path as
#    # first a Proc, then falling back to a method symbol
#    # At each stage, cache the thing we reach
#    @path.each do |step|
#      
#      #If we hit a nil cursor, can't continue
#      if !cursor
#        clear_cache
#        return
#        
#      # Try calling the step first
#      elsif (step.respond_to?(:call))
#        cursor = step.call(cursor)
#        
#      # Otherwise, use step as a method name
#      elsif (cursor.respond_to?(step))
#        cursor = cursor.send(step)  
#        
#      # Otherwise, can't continue
#      else
#        clear_cache
#        return
#      end
#      @cache.add cursor
#    end
#    
#    # Get rid of the last item in the cache, we store it separately
#    @cache.remove cursor
#    @cached_ref = cursor
#
#    # We need to end on a ref with a ref_constrain method
#    if !cursor.respond_to?(:ref_constrain)
#        clear_cache
#        return      
#    end
#    
#    # Note the cursor should end up on a ref, and we want to set
#    # the contained value to the contained value of the source
#    # Only do this if the value doesn't match already
#    new_value = @source.get
#    if !Constraints.pretty_much_same(cursor.get, new_value)
#      cursor.ref_constrain new_value, propagate
#    end
#    
#    #DEBUG
#    puts "applied reverse path #{__id__} to #{cursor.__id__}, prop? #{propagate}"
#
#    # Cache is now valid
#    @cache_valid = true
#
#  end
#
#  def priority
#    -90    
#  end
#  
#end


