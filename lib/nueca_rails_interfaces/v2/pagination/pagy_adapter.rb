# frozen_string_literal: true

require_relative 'base_adapter'

module NuecaRailsInterfaces
  module V2
    module Pagination
      # Adapter for Pagy gem.
      module PagyAdapter
        extend BaseAdapter

        def self.paginate(collection, page, per_page)
          @helper ||= Class.new { include ::Pagy::Backend }.new
          _pagy, records = @helper.send(:pagy, collection, page: page, items: per_page)
          records
        end
      end
    end
  end
end
