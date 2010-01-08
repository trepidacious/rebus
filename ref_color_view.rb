class RefColorView
  
  def initialize(ref)
    @ref = ref
    
    # Listen to ref, and update when it changes
    # see ref_number_view
    @ref.add_view self
    
    @button = Gtk::ColorButton.new(Gdk::Color.new(0,0,0))
    @button.signal_connect(:color_set) {commit}
    
    # Make the button smaller, so it will fit in a normal RefNodeView
    @button.set_height_request 16
    
    update
  end
  
  def view_data_changed changes
    update
  end

  def update
    edit_value = @button.color
    ref_value = @ref.get
    if !(edit_value == ref_value)
      @button.color = ref_value
    end
  end

  def commit
    edit_value = @button.color
    ref_value = @ref.get
    if !(edit_value == ref_value)
      @ref.set edit_value
    end
  end
  
  def widget
    @button
  end
  
  def destroy
    @ref.remove_view self
    widget.destroy
  end


end