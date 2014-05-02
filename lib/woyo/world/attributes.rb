
module Woyo

module Attributes

  module ClassMethods

    def attributes *attrs
      @attributes ||= []                 # class instance variable in ClassMethods scope
      return @attributes if attrs.empty?
      @attributes = attrs                # todo: allow additions to existing attributes
      @attributes.each do |attr|
        class_eval("
          def #{attr}= arg
            attributes[:#{attr}] = @#{attr} = arg
          end
          def #{attr}(arg=nil)
            if arg.nil?
              @#{attr}
            else
              self.#{attr} = arg
            end
          end
        ")
      end
    end

  end 

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  def attributes
    @attributes ||= {}
  end

end

end
