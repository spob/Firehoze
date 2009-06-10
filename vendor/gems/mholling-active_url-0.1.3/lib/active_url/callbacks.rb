module ActiveUrl
  module Callbacks
    def create_with_callbacks
      result = create_without_callbacks
      run_callbacks(:after_save) unless result.blank?
      result
    end
    
    def self.included(base)
      base.class_eval do
        include ActiveSupport::Callbacks # Already included by ActiveRecord.
        alias_method_chain :create, :callbacks
        define_callbacks :after_save
      end
    end
  end
end