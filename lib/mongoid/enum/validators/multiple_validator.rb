module Mongoid
  module Enum
    module Validators
      class MultipleValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, values)
          values = Array(values)

          if options[:allow_nil]
            add_error_message record, attribute if !all_included?(values, options[:in])
          else
            add_error_message record, attribute if values.empty? || !all_included?(values, options[:in])
          end
        end

        def add_error_message(record, attribute)
          record.errors[attribute] << (options[:message] || "is not in #{options[:in].join ", "}")
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
