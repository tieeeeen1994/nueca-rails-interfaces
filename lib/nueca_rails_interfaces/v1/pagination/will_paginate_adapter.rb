# frozen_string_literal: true

require_relative 'base_adapter'

module NuecaRailsInterfaces
  module V1
    module Pagination
      # Adapter for WillPaginate gem.
      module WillPaginateAdapter
        extend BaseAdapter

        def self.paginate(collection, page, per_page)
          collection.paginate(page: page, per_page: per_page)
        end
      end
    end
  end
end
