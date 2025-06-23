# frozen_string_literal: true

module NuecaRailsInterfaces
  module V1
    module DataSource
      # Data source node. They are used as actual sources of data for records,
      # may it be in terms of presentation or multiple sources of basis for data.
      # Include this module to create a data source node.
      module NodeInterface
        class << self
          # Automatically delegate missing methods to the record.
          def included(subclass)
            subclass.delegate_missing_to(:record)
          end
        end

        attr_reader :record

        # The record itself!
        def initialize(record)
          @record = record
        end
      end
    end
  end
end
