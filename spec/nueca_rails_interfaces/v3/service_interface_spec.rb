# frozen_string_literal: true

RSpec.describe NuecaRailsInterfaces::V3::ServiceInterface do
  describe 'Instance Methods' do
    describe '#perform' do
      context 'when the service is configured properly and action is truthy' do
        let(:service) do
          Class.new do
            include NuecaRailsInterfaces::V3::ServiceInterface

            def action
              'Fulfilled.'
            end

            def data
              { return: true }
            end
          end
        end
        let(:service_instance) { service.new }

        it 'performs properly' do
          expect(service_instance.perform).to eq({ return: true })
        end

        it 'marks the service as performed' do
          service_instance.perform
          expect(service_instance).to be_performed
        end

        it 'marks the service as successful' do
          service_instance.perform
          expect(service_instance).to be_success
        end
      end

      context 'when the service is configured properly and action is falsey' do
        let(:service) do
          Class.new do
            include NuecaRailsInterfaces::V3::ServiceInterface

            def action; end

            def data
              nil
            end
          end
        end
        let(:service_instance) { service.new }

        it 'performs properly' do
          expect(service_instance.perform).to be_nil
        end

        it 'marks the service as performed' do
          service_instance.perform
          expect(service_instance).to be_performed
        end

        it 'marks the service as successful' do
          service_instance.perform
          expect(service_instance).not_to be_success
        end
      end

      context 'when the service does not implement data' do
        let(:service) do
          Class.new do
            include NuecaRailsInterfaces::V3::ServiceInterface

            def action; end
          end
        end
        let(:service_instance) { service.new }

        it 'raises a NotImplementedError' do
          expect { service_instance.perform }.to raise_error(NotImplementedError, 'Requires implementation of data.')
        end
      end

      context 'when the service does not implement action' do
        let(:service) do
          Class.new do
            include NuecaRailsInterfaces::V3::ServiceInterface

            def data; end
          end
        end
        let(:service_instance) { service.new }

        it 'raises a NotImplementedError' do
          expect { service_instance.perform }.to raise_error(NotImplementedError, 'Requires implementation of action.')
        end
      end
    end

    describe '#action' do
      let(:service) do
        Class.new do
          include NuecaRailsInterfaces::V3::ServiceInterface

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

      it 'does not perform again' do
        expect(service_instance.perform).to eq(12)
      end
    end

    describe '#data' do
      let(:service) do
        Class.new do
          include NuecaRailsInterfaces::V3::ServiceInterface

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

    describe '#performed?' do
      context 'when service is not yet performed' do
        let(:service) do
          Class.new do
            include NuecaRailsInterfaces::V3::ServiceInterface

            def action; end

            def data; end
          end
        end

        it 'is not performed yet' do
          expect(service.new).not_to be_performed
        end
      end

      context 'when service is performed' do
        let(:service) do
          Class.new do
            include NuecaRailsInterfaces::V3::ServiceInterface

            def action; end

            def data; end
          end
        end
        let(:service_instance) { service.new }

        before { service_instance.perform }

        it 'is performed' do
          expect(service_instance).to be_performed
        end
      end
    end

    describe '#success?' do
      context 'when action is truthy' do
        let(:service) do
          Class.new do
            include NuecaRailsInterfaces::V3::ServiceInterface

            def action
              'Done.'
            end

            def data; end
          end
        end
        let(:service_instance) { service.new }

        before { service_instance.perform }

        it 'is successful' do
          expect(service_instance).to be_success
        end
      end

      context 'when action is falsey' do
        let(:service) do
          Class.new do
            include NuecaRailsInterfaces::V3::ServiceInterface

            def action; end

            def data; end
          end
        end
        let(:service_instance) { service.new }

        before { service_instance.perform }

        it 'is not successful' do
          expect(service_instance).not_to be_success
        end
      end
    end
  end

  describe 'Class Methods' do
    describe '#perform' do
      let(:service) do
        Class.new do
          include NuecaRailsInterfaces::V3::ServiceInterface

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

      it 'creates a new instance and quickly performs the service' do
        expect(service.perform(11)).to eq(12)
      end
    end
  end
end
