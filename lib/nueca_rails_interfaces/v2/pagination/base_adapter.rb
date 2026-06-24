# frozen_string_literal: true

module NuecaRailsInterfaces
  module V2
    module Pagination
      # Base adapter module for pagination strategies
      # Modules must implement the .paginate(collection, page, per_page) method
      module BaseAdapter
        # Paginate the collection based on the provided page and per page values.
        # @param [ActiveRecord::Relation] collection The collection to be paginated.
        # @param [Integer] page The page number.
        # @param [Integer] per_page The number of records per page.
        # @return [ActiveRecord::Relation] The paginated collection.
        def paginate(collection, page, per_page)
          raise NotImplementedError, "#{name} must implement the .paginate(collection, page, per_page) method"
        end
      end
    end
  end
end
