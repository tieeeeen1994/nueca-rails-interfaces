# frozen_string_literal: true

module Nueca
  module RailsInterfaces
    # Utility module helper.
    module Util
      def self.process_class_arguments(class_object, *arguments)
        if arguments.size == 1 && arguments.first.is_a?(Hash)
          class_object.new(**arguments.first)
        else
          class_object.new(*arguments)
        end
      end
    end
  end
end
