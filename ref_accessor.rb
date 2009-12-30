class Module

  def ref_accessor(*refs)
    
    refs.each do |ref|
      name = ref
      if name.respond_to?(:each)
        name = ref[0]
      end
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
    refs.each do |ref|
      name = ref
      klass = "nil"
      if name.respond_to?(:each)
        name = ref[0]
        klass = ref[1]
      end
      initialize_refs += "@#{name} = add_box(:#{name}, Ref.new(nil, #{klass}));"
    end
    initialize_refs += "end;"
    module_eval initialize_refs;

    default_to_s = 'def to_s();"['
    refs.each do |ref|
      name = ref
      if name.respond_to?(:each)
        name = ref[0]
      end
      default_to_s += "#{name}(" + '#{' + "#{name}.klass" + '}' + ")" + '=#{' + "#{name}" + '} '
    end
    default_to_s += ']";end;'
    module_eval default_to_s
    
  end

end
