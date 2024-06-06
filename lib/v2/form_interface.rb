# frozen_string_literal: true

module V2
  # V2 Form Interface is the same as V1 Form Interface,
  # except forces an exception on the attributes method when intializing a form.
  module FormInterface
    class << self
      # Allows the form mixin to include ActiveModel::Model powers.
      def included(base)
        base.include(ActiveModel::Model)

        # Initializes the form in a class context with the options passed in.
        base.define_singleton_method(:check) do |*arguments|
          instance = Nueca::RailsInterfaces::Util.process_class_arguments(self, *arguments)
          instance.valid?
          instance
        end
      end
    end

    # Initializes the form with the options passed in.
    # It also calls the attributes method to ensure it is implemented.
    def initialize(options = {})
      super(**options)
      attributes
    end

    # Final attributes to be returned by the form after validation.
    # This is the data that is expected of the form to produce for processing.
    # @raise [NotImplementedError] If the method is not overridden.
    def attributes
      raise NotImplementedError, 'Requires implementation of attributes.'
    end
  end
end
