class RefStringView
  
  def initialize(ref)
    @ref = ref
    
    # Listen to ref, and update when it changes
    # see ref_number_view
    @ref.add_view self
    
    @entry = Gtk::Entry.new
    @entry.signal_connect(:activate) {commit}
    
    update
  end
  
  def view_data_changed changes
    update
  end

  def update
    text = @entry.text
    value = @ref.get
    if !(text == value)
      @entry.text = value
    end
  end

  def commit
    text = @entry.text
    value = @ref.get
    if !(text == value)
      @ref.set text
    end    
  end
  
  def widget
    @entry
  end

end