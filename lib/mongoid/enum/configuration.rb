module Mongoid
  module Enum
    class Configuration
      attr_accessor :field_name_prefix
      attr_accessor :scope_method_prefix

      def initialize
        self.field_name_prefix = "_"
        self.scope_method_prefix = ""
      end
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield(configuration) if block_given?
    end
  end
end
