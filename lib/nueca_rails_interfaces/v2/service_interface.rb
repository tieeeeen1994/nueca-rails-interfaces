# frozen_string_literal: true

module NuecaRailsInterfaces
  module V2
    # V2 Service Interface is the same as V1 Service Interface, except it is more straightforward.
    # When performing the service, it will immediately return the data
    module ServiceInterface
      class << self
        def included(base)
          raise NuecaRailsInterfaces::DeprecatedError

          # This is the main method of the service in a class context.
          # This is the method that should be called to perform the service statically.
          # Use this instead if the service instance is not needed.
          # Do not override this method. Instead, override the `action` method. Returns the data immediately.
          # @return [Object] Data of the service.
          base.define_singleton_method(:perform) do |*arguments| # rubocop:disable Lint/UnreachableCode
            instance = NuecaRailsInterfaces::Util.process_class_arguments(self, *arguments)
            instance.perform
          end
        end
      end

      # This is the main method of the service. This is the method that should be called to perform the service.
      # Do not override this method. Instead, override the `action` method. Returns the data immediately.
      # @return [Object] Data of the service.
      def perform
        unless performed?
          action
          @performed = true
          process_warnings
        end

        data
      end

      # Override this method and put the main logic of the service here.
      # @raise [NotImplementedError] If the method is not overridden.
      # @return [void]
      def action
        raise NotImplementedError, 'Requires implementation of action.'
      end

      # Override this method and put the resulting data of the service here.
      # If blank, then return an empty hash manually.
      # Reason being is for readability's sake in the services.
      # @raise [NotImplementedError] If the method is not overridden.
      # @return [Object] Data of the service.
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
