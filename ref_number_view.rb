class RefNumberView
  
  def initialize(ref, min = -10000000, max = 10000000, step = 0.1, type=:spin)
    @ref = ref
    
    # Listen to ref, and update when it changes
    #@ref.add_view lambda {|x| view_data_changed x}
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
    puts "update"
    edited_value = @widget.value
    ref_value = @ref.get
    puts "edited #{edited_value}, ref #{ref_value}"
    if !(edited_value == ref_value)
      puts "updating difference"
      @widget.value = ref_value
    end
  end

  def commit
    puts "commit"
    edited_value = @widget.value
    ref_value = @ref.get
    puts "edited #{edited_value}, ref #{ref_value}"
    if !(edited_value == ref_value)
      puts "commiting difference"
      @ref.set edited_value
    end    
  end
  
  def widget
    @widget
  end

end