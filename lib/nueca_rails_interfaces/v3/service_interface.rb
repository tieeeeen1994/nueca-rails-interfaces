# frozen_string_literal: true

module NuecaRailsInterfaces
  module V3
    # V3 Service Interface adds a way for developers to determine if it was ran successfully or not.
    # When performing the service, it will immediately return the data.
    # It will also assign the success? attribute of the class.
    # The action method should return a boolean value.
    # Warnings feature is now also removed.
    module ServiceInterface
      class << self
        def included(base)
          # This is the main method of the service in a class context.
          # This is the method that should be called to perform the service statically.
          # Use this instead if the service instance is not needed.
          # Do not override this method. Instead, override the `action` method. Returns the data immediately.
          # @return [Object] Data of the service.
          base.define_singleton_method(:perform) do |*arguments|
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
          @success = action.present?
          @performed = true
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

      # Checks if the service has been performed. Do not override.
      # @return [Boolean] True or False
      def performed?
        performed
      end

      # Returns the service's status if it performed successfully or not.
      # Nil return means that the service is still not performed.
      # @return [Boolean, nil] True or False or nil
      def success?
        @success
      end

      private

      # Status of the service. If the service has been performed, this should be true.
      # Do not override this method.
      # @return [Boolean] True or False
      def performed
        @performed ||= false
      end
    end
  end
end
