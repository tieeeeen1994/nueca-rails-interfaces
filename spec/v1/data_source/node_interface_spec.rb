# frozen_string_literal: true

require 'active_model/railtie'

# Write a test for V1::DataSource::BaseInterface in RSpec.
RSpec.describe V1::DataSource::NodeInterface do
  describe '#initialize' do
    let(:record) { double }
    let(:node_instance) { Class.new { include V1::DataSource::NodeInterface }.new(record) }

    it 'sets the record' do
      expect(node_instance.record).to eq(record)
    end
  end

  context 'when a method is found in the node' do
    let(:record) { double(first_name: 'Nico') }
    let(:node) do
      Class.new do
        include V1::DataSource::NodeInterface

        def name
          "Toxic #{record.first_name}"
        end
      end
    end

    it 'delegates the method to the record' do
      expect(node.new(record).name).to eq('Toxic Nico')
    end
  end

  context 'when a method is not found in the node' do
    let(:record) { double(first_name: 'Nico') }
    let(:node) do
      Class.new do
        include V1::DataSource::NodeInterface
      end
    end

    it 'delegates the method to the record' do
      expect(node.new(record).first_name).to eq('Nico')
    end
  end

  context 'when a method is not found in both the node and the record' do
    let(:record) { double }
    let(:node) do
      Class.new do
        include V1::DataSource::NodeInterface
      end
    end

    before do
      stub_const('Node', node)
    end

    it 'raises a NoMethodError' do
      expect { node.new(record).last_name }.to raise_error(NoMethodError)
    end
  end
end
