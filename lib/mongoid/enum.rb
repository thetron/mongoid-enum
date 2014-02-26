require "mongoid/enum/version"
require "mongoid/enum/validators/multiple_validator"

module Mongoid
  module Enum
    extend ActiveSupport::Concern
    module ClassMethods
      def enum(name, values, options = {})
        field_name = :"_#{name}"
        const_name = name.to_s.upcase
        multiple = options[:multiple] || false
        default = options[:default].nil? && values.first || options[:default]
        required = options[:required].nil? || options[:required]
        validate = options[:validate].nil? || options[:validate]

        const_set const_name, values

        type = multiple && Array || Symbol
        field field_name, :type => type, :default => default
        alias_attribute name, field_name

        if multiple && validate
          validates field_name, :'mongoid/enum/validators/multiple' => { :in => values, :allow_nil => !required }
        elsif validate
          validates field_name, :inclusion => {:in => values}, :allow_nil => !required
        end

        values.each do |value|
          scope value, ->{ where(field_name => value) }

          if multiple
            class_eval "def #{value}?() self.#{field_name}.include?(:#{value}) end"
            class_eval "def #{value}!() update_attributes! :#{field_name} => (self.#{field_name} || []) + [:#{value}] end"
          else
            class_eval "def #{value}?() self.#{field_name} == :#{value} end"
            class_eval "def #{value}!() update_attributes! :#{field_name} => :#{value} end"
          end
        end
      end
    end
  end
end
