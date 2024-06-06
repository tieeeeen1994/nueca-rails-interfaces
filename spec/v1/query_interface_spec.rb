# frozen_string_literal: true

require 'active_support/all'

RSpec.describe V1::QueryInterface do
  describe 'Instance Methods' do
    describe '#call' do
      context 'when the query object is configured properly' do
        let(:query) do
          Class.new do
            include V1::QueryInterface

            private

            def filters
              @collection = [collection[0]] if query[:a].to_bool
            end

            def sorts; end
          end
        end
        let(:collection) { %i[a b c] }

        before do
          collection.class.define_method(:paginate) { |*| self }
        end

        context 'when query is nil' do
          it 'queries properly' do
            expect(query.new({}, collection).call).to eq(%i[a b c])
          end
        end

        context 'when query exists' do
          it 'queries properly' do
            expect(query.new({ a: true }, collection).call).to eq([:a])
          end
        end
      end

      # context 'when the query object does not implement sorts' do
      #   let(:query) do
      #     Class.new do
      #       include V1::QueryInterface

      #       private

      #       def filters; end
      #     end
      #   end
      #   let(:query_instance) { query.new(nil, []) }

      #   it 'raises a NotImplementedError' do
      #     expect { query_instance.call }.to raise_error(NotImplementedError, 'Requires implementation of sorts.')
      #   end
      # end

      # context 'when the query object does not implement filters' do
      #   let(:query) do
      #     Class.new do
      #       include V1::QueryInterface

      #       private

      #       def sorts; end
      #     end
      #   end
      #   let(:query_instance) { query.new(nil, []) }

      #   it 'raises a NotImplementedError' do
      #     expect { query_instance.call }.to raise_error(NotImplementedError, 'Requires implementation of filters.')
      #   end
      # end

      context 'when the query object does not correctly implement pagination settings' do
        let(:query) do
          Class.new do
            include V1::QueryInterface

            private

            def sorts; end

            def filters; end

            def pagination_settings
              { incorrect: :keys }
            end
          end
        end
        let(:query_instance) { query.new({}, []) }

        it 'raises an exception' do
          expect { query_instance.call }.to raise_error(RuntimeError, 'Invalid pagination settings.')
        end
      end
    end
  end

  describe 'Class Methods' do
    describe '#call' do
      let(:query) do
        Class.new do
          include V1::QueryInterface

          private

          def filters
            @collection = [collection[0]] if query[:a].to_bool
          end

          def sorts; end
        end
      end
      let(:collection) { %i[a b c] }

      before do
        collection.class.define_method(:paginate) { |*| self }
      end

      context 'when query is nil' do
        it 'queries properly' do
          expect(query.call({}, collection)).to eq(%i[a b c])
        end
      end

      context 'when query exists' do
        it 'queries properly' do
          expect(query.call({ a: true }, collection)).to eq([:a])
        end
      end
    end
  end
end
