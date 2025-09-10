# frozen_string_literal: true

require 'active_model/railtie'

RSpec.describe NuecaRailsInterfaces::V1::FormInterface do
  # describe 'Module Inclusion' do
  #   let(:klass) { Class.new { include NuecaRailsInterfaces::V1::FormInterface } }

  #   it 'raises a DeprecatedError when included' do
  #     expect { klass }.to raise_error(NuecaRailsInterfaces::DeprecatedError, 'This feature is deprecated.')
  #   end
  # end

  describe '#attributes' do
    context 'when the form is configured properly' do
      let(:form) do
        Class.new do
          include NuecaRailsInterfaces::V1::FormInterface

          def attributes
            { name: 'John Doe' }
          end
        end
      end

      it 'validates properly' do
        expect(form.new.valid?).to be(true)
      end

      it 'returns the attributes' do
        expect(form.new.attributes).to eq(name: 'John Doe')
      end
    end

    context 'when the form does not implement attributes' do
      let(:form) do
        Class.new do
          include NuecaRailsInterfaces::V1::FormInterface
        end
      end

      it 'raises a NotImplementedError' do
        expect { form.new.attributes }.to raise_error(NotImplementedError, 'Requires implementation of attributes.')
      end
    end
  end
end
