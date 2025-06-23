# frozen_string_literal: true

module NuecaRailsInterfaces
  module V1
    # Service Mixin Interface. Include from this module when creating a new service.
    # In this version, a service is defined as an absolute reusable piece of code.
    # They should not be related to views and presentation of data; they are instead processors.
    # Because of this, errors encountered should be raised as exceptions naturally.
    # Errors here are treated as bad data. Services are not responsible for handling bad data.
    # Services assume all data passed is correct and valid. Services should no longer validate these data.
    # Services can still store warnings; these warnings are sent to Sentry, although not yet implemented.
    # All services will have a `perform` method that will call the `action` method. This is the invoker of the service.
    # All services will have an `action` method that will contain the main logic of the service.
    # All services will have a `data` method that will contain the resulting data that the service produced.
    # Developers will mainly override `action` method and `data method`.
    module ServiceInterface
      def self.included(_)
        raise NuecaRailsInterfaces::DeprecatedError

        # Rails.logger&.warn(
        #   <<~MSG
        #     #################################################
        #     #              DEPRECATION WARNING              #
        #     # V1::ServiceInterface will be deprecated soon. #
        #     #   Please use V2::ServiceInterface instead.    #
        #     #################################################
        #   MSG
        # )
      end

      # This is the main method of the service. This is the method that should be called to perform the service.
      # Do not override this method. Instead, override the `action` method.
      # @return [self] Instance of the service.
      def perform
        unless performed?
          action
          @performed = true
          process_warnings
        end

        self
      end

      # Override this method and put the main logic of the service here.
      # @raise [NotImplementedError] If the method is not overridden.
      def action
        raise NotImplementedError, 'Requires implementation of action.'
      end

      # Override this method and put the resulting data of the service here.
      # If blank, then return an empty hash manually.
      # Reason being is for readability's sake in the services.
      # @raise [NotImplementedError] If the method is not overridden.
      def data
        raise NotImplementedError, 'Requires implementation of data.'
      end

      # Method used to add a warning. Do not override.
      # @param [String] warning_message Descriptive sentence of the warning.
      # @return [Array<String>] Array of all warnings.
      def add_warning(warning_message)
        _warnings << warning_message
        warnings
      end

      # Checks if the service has been performed. Do not override.
      # @return [Boolean] True or False
      def performed?
        performed
      end

      # Used to check if the service has encountered any warnings. Do not override.
      # @return [Boolean] True or False
      def warnings?
        _warnings.any?
      end

      # This should contain all the warnings that the service has encountered.
      # Intentionally made to be frozen to avoid free modification.
      # Do not override this method.
      # @return [Array<String>] Array of all warnings.
      def warnings
        _warnings.dup.freeze
      end

      private

      # Status of the service. If the service has been performed, this should be true.
      # Do not override this method.
      # @return [Boolean] True or False
      def performed
        @performed ||= false
      end

      # The real warnings array. Do not override this method. Use `add_warning` method to add warnings.
      # @return [Array<String>] Array of all warnings.
      def _warnings
        @warnings ||= []
      end

      # Iterates through the warnings and sends them to Sentry, supposedly. Unimplemented so far.
      # Do not override the method.
      # @return [void]
      def process_warnings; end
    end
  end
end
