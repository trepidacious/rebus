require 'gtk2'

class RefNodeView
  
#  def initialize(node)
#    @node = node
#    
#    # Make a table with a row per ref in node
#    ref_count = node.ref_names.size
#    
#    @table = Gtk::Table.new ref_count, 2
#    @table.set_row_spacings 5
#    @table.set_column_spacings 5
#
#    node.ref_names.each_with_index do |name, i|
#      # Label
#      label = Gtk::Label.new name.to_s + ":"
#      label.xalign = 1
#      label.set_width_request 140
#
#      # sub-view
#      ref = node.send(name)
#      view = Views.ref_view(ref, name)
#      view.widget.set_width_request 200
#      
#      # Layout
#      @table.attach(label, 0, 1, i, i+1, Gtk::FILL | Gtk::SHRINK, Gtk::FILL, 0, 0)
#      @table.attach(view.widget, 1, 2, i, i+1, Gtk::FILL | Gtk::EXPAND, Gtk::FILL, 0, 0)
#    end
#    
#    # FIXME need to dispose views, let them dispose Gtk stuff?
#    
#    # Listen to ref, and update when it changes
#    # @node.add_view lambda {update}
#  end

  def initialize(node)
    @node = node
    
    # Make a table with a row per ref in node
    ref_count = node.ref_names.size
    
    @label_box = Gtk::VBox.new(true, 3)
    @view_box = Gtk::VBox.new(true, 3)

    node.ref_names.each_with_index do |name, i|

      # Label
      label = Gtk::Label.new name.to_s + ":"
      label.xalign = 1
      #label.set_width_request 140

      # sub-view
      ref = node.send(name)
      view = Views.ref_view(ref, name)
      view.widget.set_width_request 200
      
      # Layout
      @label_box.pack_start(label, false, true, 0)
      @view_box.pack_start(view.widget, false, true, 0)

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