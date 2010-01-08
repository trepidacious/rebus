require 'gtk2'
require 'path_ref'

class RefNodeView2
  
  def initialize(node_ref, example)
    @node_ref = node_ref
    
    @label_box = Gtk::VBox.new(true, 6)
    @view_box = Gtk::VBox.new(true, 6)
  
    @views = Set.new

    # Add a view for each named ref in the example
    example.ref_names.each_with_index do |name, i|

      # Make a ref that is just the named ref of the displayed node, with the same class as in the example
      example_ref = example.send(name)
      ref = PathRef.new(node_ref, [name], example_ref.klass)
      
      # sub-view
      view, labelled = Views.ref_view(ref, name)
      
      if view
        #FIXME need to clear out old views when no longer used
        @views.add view
        
        view.widget.set_width_request 200
  
        # Label
        label_contents = labelled ? "" : name.to_s + ":" 
        label = Gtk::Label.new label_contents
        label.xalign = 1
        #label.set_width_request 140
        
        # Layout
        @label_box.pack_start(label, false, true, 0)
        @view_box.pack_start(view.widget, false, true, 0)
      end
      
    end
    
    @widget = Gtk::HBox.new(false, 2)
    @widget.pack_start(@label_box, false, true, 5)
    @widget.pack_start(@view_box)
    
    # FIXME need to dispose views, let them dispose Gtk stuff?
    
    # Listen to ref, and update when it changes
    # @node.add_view lambda {update}
  end
  
  def widget
    @widget
  end
  
  def destroy
    @views.each {|view| view.destroy}
    @widget.destroy
  end

end