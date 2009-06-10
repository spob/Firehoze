module ActiveUrl
  class RecordNotFound < ActiveUrlError
  end
  
  class Base
    class_inheritable_reader :attribute_names
    class_inheritable_reader :accessible_attributes
    
    def self.attribute(*attribute_names)
      options = attribute_names.extract_options!
      attribute_names.map(&:to_sym).each { |attribute_name| add_attribute(attribute_name, options) }
    end
    
    def self.attr_accessible(*attribute_names)
      self.accessible_attributes += attribute_names.map(&:to_sym)
    end
    
    attr_reader :id

    def initialize(attributes = nil)
      attributes ||= {}
      self.attributes = attributes
    end
    
    def attributes=(attributes)
      attributes.symbolize_keys.select do |key, value|
        self.class.accessible_attributes.include? key
      end.map do |key, value|
        [ "#{key}=", value ]
      end.each do |setter, value|
        send setter, value if respond_to? setter
      end
    end
    
    def attributes
      attribute_names.inject({}) do |hash, name|
        hash.merge(name => send(name))
      end
    end
    
    def create
      serialized = [ self.class.to_s, attributes ].to_yaml
      @id = Crypto.encrypt(serialized)
    end

    def save
      !create.blank?
    end
    
    def save!
      save
    end
    
    def self.find(id)
      raise RecordNotFound unless id.is_a?(String) && !id.blank?
      serialized = begin
        Crypto.decrypt(id)
      rescue Crypto::CipherError
        raise RecordNotFound
      end
      type, attributes = YAML.load(serialized)
      raise RecordNotFound unless type == self.to_s && attributes.is_a?(Hash)
      active_url = new
      attributes.each { |key, value| active_url.send "#{key}=", value }
      active_url.create
      active_url
    rescue RecordNotFound
      raise RecordNotFound.new("Couldn't find #{self.name} with id=#{id}")
    end
    
    def to_param
      @id.to_s
    end

    def new_record?
      @id.nil?
    end
    
    def ==(other)
      attributes == other.attributes && self.class == other.class
    end

    private
    
    class_inheritable_writer :attribute_names
    class_inheritable_writer :accessible_attributes
    self.attribute_names = Set.new
    self.accessible_attributes = Set.new
    
    def self.add_attribute(attribute_name, options)
      self.attribute_names << attribute_name
      self.accessible_attributes << attribute_name if options[:accessible]
      public
      attr_accessor attribute_name
    end
  end
  
  Base.class_eval do
    extend BelongsTo
    include Validations
    include Callbacks
  end
end