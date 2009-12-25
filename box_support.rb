require "weak_ref_count"

class BoxSupport

  def initialize()
    super
    @constraint_listeners = WeakRefCount.new
    @views = WeakRefCount.new
    @registered_constraints = {}
  end

  def self.delegate_methods
    [:add_view, :remove_view, :views, :constraint_listen, :constraint_unlisten, :constraint_listeners, :constraint_register, :constraint_unregister]
  end

  # View methods

  # Add a view of this box
  def add_view(listener)
    @views.add listener
  end

  # Remove a view of this box
  def remove_view(listener)
    @views.remove listener
  end

  # Get the views on this box, as
  # a WeakRefCount
  def views
    @views
  end

  # Constraint methods

  # listen as a constraint, for changes to the value
  # NOT the same as ref_constraint_register - the constraint
  # is just notified of changes to the ref, it does NOT necessarily
  # write to the ref when applied
  def constraint_listen(listener)
    @constraint_listeners.add listener
  end

  # unlisten as a constraint, for changes to the value
  def constraint_unlisten(listener)
    @constraint_listeners.remove listener
  end

  # Get the constraints that are listening to this ref, as
  # a WeakRefCount
  def constraint_listeners
    @constraint_listeners
  end
  
  # Register a constraint on this ref, this is used by 
  # constraints that will change this ref when applied, and ONLY
  # those constraints.
  def constraint_register(constraint)
    @registered_constraints[constraint] = true
  end
  
  # Unregister an unneeded constraint
  def constraint_unregister(constraint)
    @registered_constraints.delete(constraint)
  end
  
end