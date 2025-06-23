# frozen_string_literal: true

module NuecaRailsInterfaces
  module V1
    module DataSource
      # Error class for when the data source class is not found. Only use this for the context of data sources.
      class NotFound < StandardError; end

      # The data source base. Extend this module to create a data source base.
      # It is used to invoke the data source so that it automatically searches for data source nodes
      # based on the type of the record.
      module BaseInterface
        # Creates a new data source instance for the given record.
        # It will return the data source node class instance instead of itself.
        # Do not override.
        def new(record)
          record = modify_record(record)
          data_source = data_source_class(record).new(record)
          modify_data_source(data_source)
        end

        private

        # Hook for easily altering the record for processing. Override this instead of new.
        # Make sure this returns the record.
        def modify_record(record)
          record
        end

        # Hook for easily altering the detected data source for processing. Override this instead of new.
        # Make sure this returns an object that includes DataSource::Node.
        def modify_data_source(data_source)
          data_source
        end

        # Method responsible for finding the data source node for the given record. Do not override.
        # It raises a DataSouce::NotFound error if the node is not found.
        def data_source_class(record)
          resolver_logic(record)
        rescue NameError
          raise NotFound, 'Data Source node not found. Please check the namespace and class ' \
                          "name for #{record.class.name}#{" in #{namespace}" if namespace.present?}."
        end

        # Contains the logic on how to resolve the constants toward the data source node classes.
        # Override this instead of data_source_class.
        def resolver_logic(record)
          "#{namespace}::#{record.class.name}Ds".constantize
        end

        # Returns the namespace of the data source base automatically.
        # Override if needed when there is a different file stucture and different namespace.
        def namespace
          name.split('::')[0...-1].join('::')
        end
      end
    end
  end
end
