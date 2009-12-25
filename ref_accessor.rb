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
  end
end
