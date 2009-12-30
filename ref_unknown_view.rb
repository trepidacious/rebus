class RefUnknownView
  
  def initialize(ref)
    @ref = ref
    
    # Listen to ref, and update when it changes
    @ref.add_view lambda {update}
    
    @label = Gtk::Label.new("", false)
    
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