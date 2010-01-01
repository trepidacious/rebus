class RefBooleanView
  
  def initialize(ref, label)
    @ref = ref
    
    # Listen to ref, and update when it changes
    # See ref_number_view
    @ref.add_view self
    
    @check = Gtk::CheckButton.new(label)
    @check.signal_connect(:toggled) {commit}
    
    update
  end
  
  def view_data_changed changes
    update
  end

  def update
    edit_value = @check.active?
    ref_value = @ref.get
    if !(edit_value == ref_value)
      @check.active = ref_value
    end
  end

  def commit
    edit_value = @check.active?
    ref_value = @ref.get
    if !(edit_value == ref_value)
      @ref.set edit_value
    end
  end
  
  def widget
    @check
  end

end