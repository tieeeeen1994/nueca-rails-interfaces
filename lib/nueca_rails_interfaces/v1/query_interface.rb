# frozen_string_literal: true

module NuecaRailsInterfaces
  module V1
    # Query Mixin Interface. Include this module to a class that will be used as a query object.
    # Query objects are eaily identified as helpers for querying with filters and sorting with complex algorithms.
    # Thanks to ActiveRecord's inner workings, Ruby alone can handle the avdanced filtering
    # before firing the query in the database. In this version, all query objects will be paginated.
    # This is to avoid really heavy queries from hitting the database, either be it intentnional or malicious.
    # In this version, pagination is enforced but only lightly encouraged.
    # There will be a deprecation warning when no_pagination is used.
    # However, the implementation of no_pagination is still a 1 page result;
    # just that it supports a large number of queries in a single page.
    # Developers will be required to move away from V1 of Query Interface soon to enforce strict pagination.
    module QueryInterface
      # The basis for validity of pagination settings. It also contains default values.
      VALID_PAGINATION_HASH = {
        max: 20, # Absolute maximum number of records per page, even if the query requests for more.
        min: 1, # Absolute minimum number of records per page, even if the query requests for less.
        per_page: 20, # Default number of records per page if not specified in the query.
        page: 1 # Default page number if not specified in the query.
      }.freeze

      # Basis for considering a non-paging result even when the query is being processed for pagination.
      # This number states the invalidity of pagination, but it exists for legacy support.
      NO_PAGING_THRESHOLD = 1_000_000

      class << self
        def included(base)
          # This is the method to call outside this object to apply the query filters, sortings and paginations.
          # @param [Hash] query The query parameters.
          # @param [ActiveRecord::Relation] collection The collection to be queried.
          base.define_singleton_method(:call) do |query, collection|
            new(query, collection).call
          end
        end
      end

      attr_reader :query, :collection

      # Do not override! This is how we will always initialize our query objects.
      # No processing should be done in the initialize method.
      # @param [Hash] query The query parameters.
      # @param [ActiveRecord::Relation] collection The collection to be queried.
      def initialize(query, collection, pagination: true)
        @query = query
        @collection = collection
        @pagination_flag = pagination
        query_aliases
      end

      # Do not override. This is the method to call outside this object
      # to apply the query filters, sortings and paginations.
      def call
        apply_filters!
        apply_sorting!
        apply_pagination!
        collection
      end

      private

      # Place here filters. Be sure to assign @collection to override the original collection. Be sure it is private!
      def filters; end

      # Place here sorting logic. Be sure to assign @collection to override the original collection.
      # Be sure it is private!
      def sorts; end

      # Pagination settings to modify the default behavior of a query object.
      # Default values are in VALID_PAGINATION_HASH constant.
      # Override the method to change the default values.
      def pagination_settings
        {}
      end

      # Always updated alias of filters.
      def apply_filters!
        filters
      end

      # Always updated alias of sorts.
      def apply_sorting!
        sorts
      end

      # Paginates the collection based on query or settings.
      def apply_pagination!
        raise 'Invalid pagination settings.' unless correct_pagination_settings?
        return unless @pagination_flag

        @collection = collection.paginate(page: fetch_page_value, per_page: fetch_per_page_value)
      end

      # Logic for fetching the page value from the query or settings.
      def fetch_page_value
        query&.key?(:page) ? query[:page].to_i : merged_pagination_settings[:page]
      end

      # Logic for fetching the per page value from the query or settings.
      def fetch_per_page_value
        per_page = query&.key?(:per_page) ? query[:per_page].to_i : merged_pagination_settings[:per_page]
        per_page.clamp(merged_pagination_settings[:min], merged_pagination_settings[:max])
      end

      # Checks if the pagination settings are correct.
      # The app crashes on misconfiguration.
      def correct_pagination_settings?
        return false unless pagination_settings.is_a?(Hash)

        detected_keys = []
        merged_pagination_settings.each_key do |key|
          return false unless VALID_PAGINATION_HASH.key?(key)

          detected_keys << key
        end

        detected_keys.sort == VALID_PAGINATION_HASH.keys.sort
      end

      # The final result of pagination settings, and thus the used one.
      def merged_pagination_settings
        @merged_pagination_settings ||= VALID_PAGINATION_HASH.merge(pagination_settings)
      end

      # Aliases for query parameters for legacy support.
      # No need to override this in children. Directly modify this method in this interface if need be.
      def query_aliases
        query[:per_page] = query[:limit] if query[:limit].present? && query[:per_page].blank?
      end

      # For deprecation. Use this for queries that do not need pagination.
      # Queries will still be paginated as a result, but with the use of the threshold,
      # the result is as good as a non-paginated result,
      # and it will be treated as such.
      def no_pagination
        Rails.logger.warn 'Querying without paging is deprecated. Enforce paging in queries!'
        { max: NO_PAGING_THRESHOLD, min: NO_PAGING_THRESHOLD }
      end
    end
  end
end
