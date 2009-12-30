require "delegate"
require "change_manager"
require "box_support"
require "forwardable"
require "simple_change"
require "ref"

class NodeConstraint
  
  def initialize(node, boxes = {})
    @node = node
    
    # register on target, so it keeps us in scope
    @node.constraint_register self
    
    #Listen to all initial boxes
    boxes.each {|box| add box} if boxes
  end

  def add(box)
    box.constraint_listen self
  end

  def remove(box)
    box.constraint_unlisten self
  end

  def propagate(changes)
    # If any contained box changes, the node changes
    {@node => SimpleChange.deep}
  end
  
  def apply(propagate)
    # Nothing to do, we are just propagating changes
  end
  
end

# A Box that references multiple other Boxes, and changes
# in a deep way when they change.
# This is a Box, and so can be viewed and constrained
class Node
  
  def initialize(boxes = nil, change_manager = nil)
    @support = BoxSupport.new
    #Default to shared change manager instance
    @change_manager = change_manager || ChangeManager.instance
    @constraint = NodeConstraint.new self, boxes
    @refs = {}
  end

  # Delegate Box methods to @support
  extend Forwardable
  def_delegators :@support, *BoxSupport.delegate_methods

  def refs
    @refs
  end

  def add_box(name = nil, box = nil)
    if !box
      box = Ref.new
    end
    @constraint.add box
    if name
      @refs[name] = box
    end
    box
  end

end