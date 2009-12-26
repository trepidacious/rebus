class RefSpinnerView
  
  def initialize(ref, min = -10000000, max = 10000000, step = 0.1)
    @ref = ref
    
    # Listen to ref, and update when it changes
    @ref.add_view lambda {update}
    
    @spinner = Gtk::SpinButton.new(min, max, step)
    @spinner.signal_connect(:value_changed) {commit}
    
    update
  end
  
  def update
    edited_value = @spinner.value
    ref_value = @ref.get
    if !(edited_value == ref_value)
      @spinner.value = ref_value
    end
  end

  def commit
    edited_value = @spinner.value
    ref_value = @ref.get
    if !(edited_value == ref_value)
      @ref.set edited_value
    end    
  end
  
  def widget
    @spinner
  end

end