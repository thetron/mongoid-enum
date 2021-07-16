# frozen_string_literal: true

module Mongoid
  module Enum
    module Validators
      class MultipleValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, values)
          values = Array(values)

          if options[:allow_nil]
            add_error_message record, attribute unless all_included?(values, options[:in])
          elsif values.empty? || !all_included?(values, options[:in])
            add_error_message record, attribute
          end
        end

        def add_error_message(record, attribute)
          record.errors[attribute] << (options[:message] || "is not in #{options[:in].join ', '}")
        end

        def all_included?(values, allowed)
          (values - allowed).empty?
        end

        def self.kind
          :custom
        end
      end
    end
  end
end
