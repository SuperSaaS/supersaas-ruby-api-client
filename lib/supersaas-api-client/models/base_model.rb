module Supersaas
  class BaseModel
    attr_accessor :errors
    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes
      assign_attributes(attributes)
    end

    private

    def assign_attributes(attributes)
      attributes.each do |key, value|
        self.class.module_eval { attr_accessor key }
        public_send("#{key}=", value) if respond_to?("#{key}=")
      end
    end
  end
end