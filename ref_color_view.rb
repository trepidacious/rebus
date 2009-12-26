class RefColorView
  
  def initialize(ref)
    @ref = ref
    
    # Listen to ref, and update when it changes
    @ref.add_view lambda {update}
    
    @button = Gtk::ColorButton.new(Gdk::Color.new(0,0,0))
    @button.signal_connect(:color_set) {commit}
    
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

end