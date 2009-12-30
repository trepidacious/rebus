class Module

  def ref_accessor(refs)
    
    # If we get an array, then convert it into
    # a hash from each name to nil klass, otherwise
    # just use it
    names = refs;
    if (!refs.respond_to?(:each_pair))
      names = {}
      refs.each {|name| names[name] = "nil"}
    end

    names.each_key do |name|
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
    names.each_pair do |name, klass|
      initialize_refs += "@#{name} = add_box(:#{name}, Ref.new(nil, #{klass}));"
    end
    initialize_refs += "end;"
    module_eval initialize_refs;

    default_to_s = 'def to_s();"['
    names.each_pair do |name, klass|
      default_to_s += "#{name}(" + '#{' + "#{name}.klass" + '}' + ")" + '=#{' + "#{name}" + '} '
    end
    default_to_s += ']";end;'
    module_eval default_to_s
    
  end

end
