# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NuecaRailsInterfaces::V1::Pagination do
  describe NuecaRailsInterfaces::V1::Pagination::BaseAdapter do
    it 'raises NotImplementedError when calling .paginate on a module that extends it but does not override it' do
      dummy_adapter = Module.new { extend NuecaRailsInterfaces::V1::Pagination::BaseAdapter }
      expect { dummy_adapter.paginate(double('Collection'), 1, 10) }
        .to raise_error(NotImplementedError, /must implement the .paginate/)
    end
  end

  describe NuecaRailsInterfaces::V1::Pagination::WillPaginateAdapter do
    it 'delegates pagination using the .paginate method signature' do
      collection = double('ActiveRecord_Relation', paginate: nil)

      described_class.paginate(collection, 2, 15)

      expect(collection).to have_received(:paginate).with(page: 2, per_page: 15)
    end
  end

  describe NuecaRailsInterfaces::V1::Pagination::KaminariAdapter do
    it 'delegates pagination using the chainable .page.per method signature' do
      relation_with_page = double('Relation_With_Page', per: nil)
      collection = double('ActiveRecord_Relation')
      allow(collection).to receive(:page).with(2).and_return(relation_with_page)

      described_class.paginate(collection, 2, 15)

      expect(collection).to have_received(:page).with(2)
      expect(relation_with_page).to have_received(:per).with(15)
    end
  end

  describe NuecaRailsInterfaces::V1::Pagination::PagyAdapter do
    it 'delegates pagination using the pagy method' do
      collection = double('ActiveRecord_Relation')
      pagy_backend = Module.new do
        def pagy(*_args, **_kwargs)
          [:pagy_metadata, :paginated_records]
        end
      end
      stub_const('Pagy', Module.new)
      stub_const('Pagy::Backend', pagy_backend)

      expect(described_class.paginate(collection, 2, 15)).to eq(:paginated_records)
    end
  end

  describe 'Adapter Auto-Detection' do
    let(:query_class) do
      Class.new do
        include NuecaRailsInterfaces::V1::QueryInterface

        private

        def filters; end
        def sorts; end
      end
    end
    let(:collection) { double('Collection', respond_to?: false) }
    let(:query_instance) { query_class.new({}, collection) }

    context 'when WillPaginate is defined' do
      before do
        stub_const('WillPaginate', Module.new)
        hide_const('Kaminari')
        hide_const('Pagy')
      end

      it 'selects the WillPaginateAdapter' do
        expect(query_instance.send(:pagination_adapter)).to eq(NuecaRailsInterfaces::V1::Pagination::WillPaginateAdapter)
      end
    end

    context 'when Kaminari is defined' do
      before do
        hide_const('WillPaginate')
        stub_const('Kaminari', Module.new)
        hide_const('Pagy')
      end

      it 'selects the KaminariAdapter' do
        expect(query_instance.send(:pagination_adapter)).to eq(NuecaRailsInterfaces::V1::Pagination::KaminariAdapter)
      end
    end

    context 'when Pagy is defined' do
      before do
        hide_const('WillPaginate')
        hide_const('Kaminari')
        stub_const('Pagy', Module.new)
      end

      it 'selects the PagyAdapter' do
        expect(query_instance.send(:pagination_adapter)).to eq(NuecaRailsInterfaces::V1::Pagination::PagyAdapter)
      end
    end

    context 'when neither is defined and collection does not respond to paginate' do
      before do
        hide_const('WillPaginate')
        hide_const('Kaminari')
        hide_const('Pagy')
        allow(collection).to receive(:respond_to?).with(:paginate).and_return(false)
      end

      it 'raises an error' do
        expect { query_instance.send(:pagination_adapter) }.to raise_error(
          RuntimeError,
          /No compatible pagination library detected/
        )
      end
    end
  end
end
