class Module
  
  def ref_accessor(*names)
    names.each do |name|
      module_eval <<-END_OF_CODE
        def #{name}
          @#{name}
        end
        def #{name}=(value)
         @#{name}.set value
        end
      END_OF_CODE
    end

    initialize_refs = "def initialize_refs();"
    names.each do |name|
      initialize_refs += "@#{name} = add_box :#{name};"
    end
    initialize_refs += "end;"
    module_eval initialize_refs;

    default_to_s = 'def to_s();"['
    names.each do |name|
      default_to_s += "#{name}" + ' = #{' + "#{name}" + '} '
    end
    default_to_s += ']";end;'
    module_eval default_to_s

  end

end
