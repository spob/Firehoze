module ActiveUrl
  class RecordInvalid < ActiveUrlError
    attr_reader :record
    def initialize(record)
      @record = record
      super("Validation failed: #{@record.errors.full_messages.join(", ")}")
    end
  end

  module Validations
    module ClassMethods
      def self_and_descendants_from_active_record
        [self]
      end
      alias_method :self_and_descendents_from_active_record, :self_and_descendants_from_active_record
      
      def human_name()
      end
      
      def human_attribute_name(name, options = {})
        name.to_s.humanize
      end
      
      def find_with_validation(id)
        active_url = find_without_validation(id)
        raise ActiveUrl::RecordNotFound unless active_url.valid?
        active_url
      end
      
      private
      
      def add_attribute_with_validation(attribute_name, options)
        add_attribute_without_validation(attribute_name, options)
        alias_method "#{attribute_name}_before_type_cast", attribute_name
      end
        
    end
    
    def save_with_active_url_exception!
      save_without_active_url_exception!
    rescue ActiveRecord::RecordInvalid => e
      raise ActiveUrl::RecordInvalid.new(e.record)
    end

    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include ActiveRecord::Validations
        alias_method_chain :save!, :active_url_exception
        class << self
          alias_method_chain :find, :validation
          alias_method_chain :add_attribute, :validation
        end
      end
    end
  end
end