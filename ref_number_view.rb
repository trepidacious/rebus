class RefNumberView
  
  def initialize(ref, min = -10000000, max = 10000000, step = 0.1, type=:spin)
    @ref = ref
    
    # Listen to ref, and update when it changes
    @ref.add_view lambda {update}

    if type == :scale
      @widget = Gtk::HScale.new(min, max, step)
      @widget.value_pos = Gtk::POS_LEFT
    else
      @widget = Gtk::SpinButton.new(min, max, step)      
    end

    @widget.signal_connect(:value_changed) {commit}
    
    update
  end
  
  def update
    edited_value = @widget.value
    ref_value = @ref.get
    if !(edited_value == ref_value)
      @widget.value = ref_value
    end
  end

  def commit
    edited_value = @widget.value
    ref_value = @ref.get
    if !(edited_value == ref_value)
      @ref.set edited_value
    end    
  end
  
  def widget
    @widget
  end

end