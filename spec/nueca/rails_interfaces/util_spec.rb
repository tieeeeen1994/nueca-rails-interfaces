# frozen_string_literal: true

RSpec.describe Nueca::RailsInterfaces::Util do
  describe '#self.process_class_arguments' do
    context 'when the argument is one and is not a Hash' do
      it 'correctly returns the instance' do
        expect(described_class.process_class_arguments(String, 'test')).to eq('test')
      end
    end

    context 'when the argument is one and is a Hash' do
      let(:class_object) do
        Class.new do
          def initialize(**options)
            check(**options)
          end

          def check(test:); end
        end
      end
      let(:expected) { { test: 'test' } }

      it 'correctly initializes the instance' do
        expect(described_class.process_class_arguments(class_object, **expected)).to be_an_instance_of(class_object)
      end
    end

    context 'when there are multiple arguments' do
      it 'correctly returns the instance' do
        expect(described_class.process_class_arguments(Array, 3, 0)).to eq([0, 0, 0])
      end
    end
  end
end
