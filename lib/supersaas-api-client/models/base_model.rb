# frozen_string_literal: true

module Supersaas
  class BaseModel
    attr_accessor :errors
    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes
      assign_attributes(attributes)
    end

    # Hash-style access to the raw attribute value, with a String or Symbol key.
    # Keeps code working that read nested data as a Hash, e.g. appointment.form['content'].
    def [](key)
      return attributes[key] if attributes.key?(key)

      case key
      when Symbol then attributes[key.to_s]
      when String then attributes[key.to_sym]
      end
    end

    def to_h
      attributes.to_h
    end

    private

    def assign_attributes(attributes)
      attributes.each do |key, value|
        # Keep custom writers such as Appointment#form=, which wrap nested data in models
        self.class.module_eval { attr_accessor key } unless self.class.method_defined?("#{key}=")
        public_send("#{key}=", value)
      end
    end
  end
end
