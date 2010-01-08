require 'gtk2'

class RefNodeView
  
  def initialize(node)
    @node = node
    
    @label_box = Gtk::VBox.new(true, 6)
    @view_box = Gtk::VBox.new(true, 6)
  
    @views = Set.new

    node.ref_names.each_with_index do |name, i|

      # sub-view
      ref = node.send(name)
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

end