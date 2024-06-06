# frozen_string_literal: true

require 'active_model/railtie'

RSpec.describe V1::FormInterface do
  describe '#attributes' do
    context 'when the form is configured properly' do
      let(:form) do
        Class.new do
          include V1::FormInterface
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
          include V1::FormInterface
        end
      end

      it 'raises a NotImplementedError' do
        expect { form.new.attributes }.to raise_error(NotImplementedError, 'Requires implementation of attributes.')
      end
    end
  end
end
