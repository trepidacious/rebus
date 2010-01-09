class RefNumberView
  
  def initialize(ref, min = -1000000000, max = 1000000000, step = 0.1, type=:spin)
    @ref = ref
    
    # Listen to ref, and update when it changes
    # Note we don't use a lambda since it could be GCed unless
    # we retain a reference to it
    @ref.add_view self

    if type == :scale
      @widget = Gtk::HScale.new(min, max, step)
      @widget.value_pos = Gtk::POS_LEFT
    else
      @widget = Gtk::SpinButton.new(min, max, step)      
    end

    @widget.signal_connect(:value_changed) {commit}
    
    update
  end
  
  def view_data_changed changes
    update
  end
  
  def update
    edited_value = @widget.value
    ref_value = @ref.get
    #puts "update, edited #{edited_value}, ref #{ref_value}"
    if !(edited_value == ref_value)
      @widget.value = ref_value
    end
  end

  def commit
    edited_value = @widget.value
    ref_value = @ref.get
    #puts "commit, edited #{edited_value}, ref #{ref_value}"
    if !(edited_value == ref_value)
      @ref.set edited_value
    end    
  end
  
  def widget
    @widget
  end
  
  def destroy
    @ref.remove_view self
    widget.destroy
  end


end