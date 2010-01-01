require 'ref'
require 'gtk2'
require 'ref_string_view'
require 'ref_number_view'
require 'ref_boolean_view'
require 'ref_color_view'
require 'ref_unknown_view'

class Views

  def self.ref_view(ref, label = "", show_unknown = false)
    
    klass = ref.klass
    
    if klass == String
      return RefStringView.new(ref), false
    elsif klass == Fixnum
      return RefNumberView.new(ref, -10000000, 10000000, 1), false
    elsif klass == Float
      return RefNumberView.new(ref, -10000000, 10000000, 0.1), false
    elsif klass == TrueClass || klass == FalseClass
      return RefBooleanView.new(ref, label), true
    elsif klass == Gdk::Color
      return RefColorView.new(ref), false
      
    # Everything else including nil goes to generic unknown view,
    # if this is enabled
    elsif show_unknown
      return RefUnknownView.new(ref), false
      
    # Otherwise, no view
    else
      return nil
    end
  end

end