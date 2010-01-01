class RefUnknownView
  
  def initialize(ref)
    @ref = ref
    
    # Listen to ref, and update when it changes
    # see ref_number_view
    @ref.add_view self
    
    @label = Gtk::Label.new("", false)
    
    update
  end
  
  def view_data_changed changes
    update
  end

  def update
    text = @label.text
    value = @ref.get
    if !(text == value)
      @label.text = value.to_s
    end
  end

  def widget
    @label
  end

end