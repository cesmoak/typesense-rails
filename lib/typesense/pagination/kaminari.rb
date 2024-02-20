unless defined? Kaminari
  raise(Typesense::Error::MissingConfiguration,
        "Typesense: Please add 'kaminari' to your Gemfile to use kaminari pagination backend")
end

require 'kaminari/models/array_extension'

module Typesense
  module Pagination
    class Kaminari < ::Kaminari::PaginatableArray
      def initialize(array, options)
        @_options = options
        super(array)
      end

      def total_count
        @_options[:total_count]
      end

      def total_pages
        (@_options[:total_count].to_f / @_options[:limit]).ceil
      end

      def current_page
        @_options[:page]
      end

      def offset_value
        @_options[:offset]
      end

      def limit_value
        @_options[:limit]
      end

      def limit(_num)
        # noop
        self
      end

      def offset(_num)
        # noop
        self
      end

      class << self
        def create(results, total_hits, options = {})
          offset = ((options[:page] - 1) * options[:per_page])
          array = new results, { offset: offset, limit: options[:per_page], total_count: total_hits, page: options[:page] }
          if array.empty? && !results.empty?
            # since Kaminari 0.16.0, you need to pad the results with nil values so it matches the offset param
            # otherwise you'll get an empty array: https://github.com/amatsuda/kaminari/commit/29fdcfa8865f2021f710adaedb41b7a7b081e34d
            results = ([nil] * offset) + results
            array = new results, { offset: offset, limit: options[:per_page], total_count: total_hits, page: options[:page] }
          end
          array
        end
      end
    end
  end
end
