require "mongoid/enum/version"
require "mongoid/enum/validators/multiple_validator"

module Mongoid
  module Enum
    extend ActiveSupport::Concern
    module ClassMethods

      def enum(name, values, options = {})
        field_name = :"_#{name}"
        options = default_options(values).merge(options)

        set_values_constant name, values

        create_field field_name, options
        alias_attribute name, field_name

        create_validations field_name, values, options
        define_value_scopes_and_accessors field_name, values, options
      end

      private
      def default_options(values)
        {
          :multiple => false,
          :default  => values.first,
          :required => true,
          :validate => true
        }
      end

      def set_values_constant(name, values)
        const_name = name.to_s.upcase
        const_set const_name, values
      end

      def create_field(field_name, options)
        type = options[:multiple] && Array || Symbol
        field field_name, :type => type, :default => options[:default]
      end

      def create_validations(field_name, values, options)
        if options[:multiple] && options[:validate]
          validates field_name, :'mongoid/enum/validators/multiple' => { :in => values, :allow_nil => !options[:required] }
        elsif validate
          validates field_name, :inclusion => {:in => values}, :allow_nil => !options[:required]
        end
      end

      def define_value_scopes_and_accessors(field_name, values, options)
        values.each do |value|
          scope value, ->{ where(field_name => value) }

          if options[:multiple]
            define_array_accessor(field_name, value)
          else
            define_string_accessor(field_name, value)
          end
        end
      end

      def define_array_accessor(field_name, value)
        class_eval "def #{value}?() self.#{field_name}.include?(:#{value}) end"
        class_eval "def #{value}!() update_attributes! :#{field_name} => (self.#{field_name} || []) + [:#{value}] end"
      end

      def define_string_accessor(field_name, value)
        class_eval "def #{value}?() self.#{field_name} == :#{value} end"
        class_eval "def #{value}!() update_attributes! :#{field_name} => :#{value} end"
      end
    end
  end
end
