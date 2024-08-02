# frozen_string_literal: true

require 'active_model/railtie'

# Write a test for V1::DataSource::BaseInterface in RSpec.
RSpec.describe V1::DataSource::BaseInterface do
  describe '#new' do
    context 'when data source node is known' do
      let(:interfase) do
        Class.new do
          extend V1::DataSource::BaseInterface
        end
      end
      let(:record) { double }
      let(:data_source_node_class) { double }
      let(:data_source_node_instance) { double }

      before do
        allow(interfase).to receive(:resolver_logic).and_return(data_source_node_class)
        allow(data_source_node_class).to receive(:new).and_return(data_source_node_instance)
      end

      it 'creates a new data source instance for the given record' do
        expect(interfase.new(record)).to eq(data_source_node_instance)
      end
    end

    context 'when data source node is not found' do
      let(:interfase) do
        Class.new do
          extend V1::DataSource::BaseInterface
        end
      end
      let(:record) { double }

      before do
        allow(interfase).to receive(:resolver_logic).and_raise(NameError)
        allow(interfase).to receive(:namespace).and_return('')
      end

      it 'raises a DataSource::NotFound error' do
        expect { interfase.new(record) }.to raise_error(V1::DataSource::NotFound)
      end
    end
  end

  describe '#resolver_logic' do
    let(:base_data_source) do
      Class.new do
        extend V1::DataSource::BaseInterface
      end
    end
    let(:node_data_source) do
      Class.new do
        include V1::DataSource::NodeInterface
      end
    end
    let(:record_class) do
      Class.new do
        def name
          'toxic_nico'
        end
      end
    end
    let(:base) { base_data_source.new(record) }

    before do
      stub_const('Nueca::UserDs', node_data_source)
      stub_const('Nueca::DataSource', base_data_source)
      stub_const('User', record_class)
    end

    it 'returns the data source node class for the given record' do
      expect(base.class.to_s).to eq('Nueca::UserDs')
    end

    it 'passes the record to the node' do
      expect(base.name).to eq('toxic_nico')
    end
  end
end
