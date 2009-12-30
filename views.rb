require 'ref'
require 'gtk2'
require 'ref_string_view'
require 'ref_number_view'
require 'ref_boolean_view'
require 'ref_color_view'
require 'ref_unknown_view'

class Views

  def self.ref_view(ref, label = "")
    
    klass = ref.klass
    
    if klass == String
      return RefStringView.new ref
    elsif klass == Fixnum
      return RefNumberView.new ref
    elsif klass == Float
      return RefNumberView.new ref
    elsif klass == TrueClass || klass == FalseClass
      return RefBooleanView.new ref, label
    elsif klass == Gdk::Color
      return RefColorView.new ref
      
    #Everything else including nil goes to generic unknown view
    else
      return RefUnknownView.new ref
    end
  end

end