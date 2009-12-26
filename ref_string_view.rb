class RefStringView
  
  def initialize(ref)
    @ref = ref
    
    # Listen to ref, and update when it changes
    @ref.add_view lambda {update}
    
    @entry = Gtk::Entry.new
    @entry.signal_connect(:activate) {commit}
    
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