# frozen_string_literal: true

RSpec.describe V1::ServiceInterface do
  describe '#perform' do
    context 'when the service is configured properly' do
      let(:service) do
        Class.new do
          include V1::ServiceInterface
          def action; end
          def data; end
        end
      end
      let(:service_instance) { service.new }

      it 'performs properly' do
        expect(service_instance.perform).to eq(service_instance)
      end

      it 'marks the service as performed' do
        service_instance.perform
        expect(service_instance).to be_performed
      end
    end

    context 'when the service does not implement data' do
      let(:service) do
        Class.new do
          include V1::ServiceInterface
          def action; end
        end
      end

      it 'raises a NotImplementedError' do
        expect { service.new.data }.to raise_error(NotImplementedError, 'Requires implementation of data.')
      end
    end

    context 'when the service does not implement action' do
      let(:service) do
        Class.new do
          include V1::ServiceInterface
          def data; end
        end
      end

      it 'raises a NotImplementedError' do
        expect { service.new.perform }.to raise_error(NotImplementedError, 'Requires implementation of action.')
      end
    end
  end

  describe '#action' do
    let(:service) do
      Class.new do
        include V1::ServiceInterface

        def initialize(number)
          @number = number
        end

        def action
          @number += 1
        end

        def data
          @number
        end
      end
    end
    let(:service_instance) { service.new(11) }

    before { service_instance.perform }

    it 'executes the action successfully' do
      expect(service_instance.data).to eq(12)
    end
  end

  describe '#data' do
    let(:service) do
      Class.new do
        include V1::ServiceInterface

        def action; end

        def data
          { key: 'value' }
        end
      end
    end
    let(:service_instance) { service.new }

    it 'returns the data' do
      expect(service_instance.data).to have_key(:key)
    end
  end

  describe '#warnings' do
    let(:service) do
      Class.new do
        include V1::ServiceInterface

        def action
          add_warning('Test Warning...')
        end

        def data
          { all_warnings: warnings }
        end
      end
    end
    let(:service_instance) { service.new }

    before { service_instance.perform }

    it 'has warnings' do
      expect(service_instance.warnings).not_to be_empty
    end

    it 'flags existence of warnings' do
      expect(service_instance.warnings?).to be(true)
    end

    it 'does not allow modification of warnings' do
      add_warning = -> { service_instance.warnings << 'Another Warning...' }
      expect { add_warning.call }.to raise_error(FrozenError, /can't modify frozen Array/)
    end

    it 'does not have access to real warnings' do
      expect { service_instance._warnings }.to raise_error(NoMethodError, /private method `_warnings' called/)
    end
  end
end
