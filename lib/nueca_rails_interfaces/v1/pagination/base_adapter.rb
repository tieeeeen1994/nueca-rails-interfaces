# frozen_string_literal: true

module NuecaRailsInterfaces
  module V1
    module Pagination
      # Base adapter module for pagination strategies
      module BaseAdapter
        def paginate(collection, page, per_page)
          raise NotImplementedError, "#{name} must implement the .paginate(collection, page, per_page) method"
        end
      end
    end
  end
end
