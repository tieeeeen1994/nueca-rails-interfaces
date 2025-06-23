# frozen_string_literal: true

module NuecaRailsInterfaces
  module V1
    # Form Interface. Include this module to create a new form.
    # In this version, a form is defined as a data verifier, mainly coming from parameters
    # to shoulder off validation from processors such as services and interactors, or action controllers.
    # A form should be treated like a custom model without the need for a database.
    # Forms are responsible for validating data and returning the data in a format that is ready for processing.
    # Forms are responsible for handling bad data, returning errors provided by ActiveModel.
    # Forms should implement the `attributes` method to define the attributes of the form.
    # Forms should not override methods from ActiveModel for customization.
    # The `attributes` method should return a hash of the attributes of the form (strictly not an array).
    # It is up to the developer what `attributes` method will contain if there is an error. Treat as such like an API.
    module FormInterface
      # Allows the form mixin to include ActiveModel::Model powers.
      # @param [self] base Instance of the base form that would include this module.
      # @return [void]
      def self.included(_base)
        raise NuecaRailsInterfaces::DeprecatedError

        # base.include(ActiveModel::Model)
        # Rails.logger&.warn(
        #   <<~MSG
        #     ##############################################
        #     #            DEPRECATION WARNING             #
        #     # V1::FormInterface will be deprecated soon. #
        #     #    Please use V2::FormInterface instead.   #
        #     ##############################################
        #   MSG
        # )
      end

      # Final attributes to be returned by the form after validation.
      # This is the data that is expected of the form to produce for processing.
      # @raise [NotImplementedError] If the method is not overridden.
      def attributes
        raise NotImplementedError, 'Requires implementation of attributes.'
      end
    end
  end
end
