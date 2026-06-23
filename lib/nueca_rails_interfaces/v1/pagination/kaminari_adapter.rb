# frozen_string_literal: true

require_relative 'base_adapter'

module NuecaRailsInterfaces
  module V1
    module Pagination
      # Adapter for Kaminari gem.
      module KaminariAdapter
        extend BaseAdapter

        def self.paginate(collection, page, per_page)
          collection.page(page).per(per_page)
        end
      end
    end
  end
end
