require "set"

class ChangeManager

  def initialize()
    #FIXME These maps need to be identity hashes, but for now all data/refs implement eql? by identity
    @changes = {}
    @all_changes = {}
    @data_to_constraint = {}
    @constraints_changing_unknown = SortedSet.new
    @notifying_views = false
  end
  
  @@the_instance = ChangeManager.new
  def self.instance
    @@the_instance
  end

  def before_read (data)
    
    # We know the constraints are ones with defined targets,
    # which will not produce additional changes, so we just need to
    # apply changes
    
    # Get the set of constraints for this data, and copy it.
    # We will apply these constraints only - any others
    # are not needed. If this value depends on others,
    # then their constraints will be triggered recursively.
    constraints = (@data_to_constraint[data] || SortedSet.new).dup

    # Since we will be applying constraints, we do not
    # need to apply them again. We KNOW we will apply them
    # eventually, so we can remove them now, but we will apply
    # them below.
    @data_to_constraint.each_key do |c|
      relevant_constraints = @data_to_constraint[c] || SortedSet.new
      relevant_constraints.subtract constraints
    end
    
    # Get rid of the whole set of constraints we are applying,
    # no point keeping mapping to empty set
    @data_to_constraint.delete(data)

    # Get rid of any OTHER empty constraint sets, in case
    # we just cleared the last ones out of some other data 
    @data_to_constraint.delete_if {|k, v| v.empty?}

    # Finally, apply the constraints - they don't need to propagate,
    # we did it during earlier propagation
    constraints.each do |constraint|
      constraint.apply false
    end

#   Alternate version, simpler but may apply the same constraint twice if it affects different targets
#    while @data_to_constraint[data] do
#      constraints = @data_to_constraint[data]
#      constraint = constraints.first
#      if (constraint)
#        constraints.delete constraint
#        constraint.apply false
#      end
#      @data_to_constraint.delete_if {|k, v| v.empty?}
#    end

  end

  def before_change (changed)
    if @notifying_views
      raise "Cannot make a change from a listening view"
    end
  end

  def after_change (changed, change)

    # Do normal change propagation
    propagate_change(changed, change)
    coalesce_changes
    
    # Keep applying "undefined" constraints until they resolve
    # We need to apply them NOW, rather than waiting for a read,
    # since we need to notify any views about changes the
    # "undefined" constraints may make.
    # Note if/when we coalesce, we don't need to do this step
    # until we are just about to notify views - it doesn't have
    # to happen after every change propagation 
    while !@constraints_changing_unknown.empty? do
      first_constraint = @constraints_changing_unknown.first
      @constraints_changing_unknown.delete first_constraint
      
      # Constraint must request propagation
      first_constraint.apply true
    end
    
    @notifying_views = true
    
    # Now we need to build a set of external listeners,
    # and tell them
    all_views = Set.new
    @all_changes.each_key do |x|
      x.views.each do |view| 
        all_views.add view
      end
    end

    all_views.each do |view|
      if view.respond_to?(:view_data_changed)
        view.view_data_changed @all_changes
      elsif view.respond_to?(:call)
        view.call @all_changes
      else
        puts "####Invalid view #{view}"
      end
    
    end
    
    # Now clear the changes
    @all_changes.clear
    
    @notifying_views = false
    
  end
  
  private
  
  def propagate_change (changed, change)
    
    # If this change actually extends the change for changed,
    # we will need to tell constraints
    if extend_change(@changes, changed, change)
      
      # Tell all listening constraints
      constraints = changed.constraint_listeners
      constraints.each do |constraint|
        
        new_changes = constraint.propagate(@changes) || {}

        propagate_changes(constraint, new_changes)
        
      end
    end    
  end
  
  def propagate_changes(constraint, new_changes)
        
    # Propagate the new changes to listeners recursively
    new_changes.each_pair do |new_changed, new_change|
    
      # Add this constraint to the set for this changed data
      constraint_set = @data_to_constraint[new_changed]
      if !constraint_set
        constraint_set = SortedSet.new
        @data_to_constraint[new_changed] = constraint_set
      end
      constraint_set.add constraint
      
      # If the changed item is the symbol :unknown, we treat this
      # as a special change, indicating that the constraint
      # doesn't know which data it will change
      # NOTE: We use eql? because it works, and it doesn't cause a read on the ref
      # via delegation, which == does.
      if (new_changed.eql? :unknown)
        @constraints_changing_unknown.add constraint
      # Normal changes are just propagated
      else
        propagate_change(new_changed, new_change)
      end

    end
  end
  
  def extend_change(changes, changed, change)
    existing = changes[changed]
    if (existing)
      extended = existing.extend(change)
      if (extended)
        changes[changed] = extended
        return true
      end
    else
      changes[changed] = change
      return true
    end
  end
  
  def coalesce_changes
    @changes.each_pair do |k, v|
      extend_change(@all_changes, k, v)
    end
    @changes.clear
  end

end
