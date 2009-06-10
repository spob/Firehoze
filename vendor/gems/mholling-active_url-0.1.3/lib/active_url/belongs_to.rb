module ActiveUrl
  module BelongsTo
    def belongs_to(object_name)
      begin
        object_name.to_s.classify.constantize
      
        attribute_name = "#{object_name}_id"
        attribute attribute_name
    
        define_method object_name do
          begin
            object_name.to_s.classify.constantize.find(send(attribute_name))
          rescue ActiveRecord::RecordNotFound
            nil
          end
        end
    
        define_method "#{object_name}=" do |object|
          if object.nil?
            self.send "#{object_name}_id=", nil
          elsif object.is_a?(object_name.to_s.classify.constantize)
            self.send "#{object_name}_id=", object.id
          else
            raise TypeError.new("object is not of type #{object_name.to_s.classify}")
          end
        end
      rescue NameError
        raise ArgumentError.new("#{object_name.to_s.classify} is not an ActiveRecord class.")
      end
    end
  end
end