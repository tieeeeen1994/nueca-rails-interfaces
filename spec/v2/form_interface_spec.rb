# frozen_string_literal: true

require 'active_model/railtie'

RSpec.describe V2::FormInterface do
  describe 'Instance Methods' do
    describe '#attributes' do
      context 'when the form is configured properly' do
        let(:form) do
          Class.new do
            include V2::FormInterface
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
            include V2::FormInterface
          end
        end

        it 'raises a NotImplementedError on initialization' do
          expect { form.new }.to raise_error(NotImplementedError, 'Requires implementation of attributes.')
        end
      end
    end
  end

  describe 'Class Methods' do
    describe '#check' do
      context 'when the form is configured properly' do
        let(:form) do
          Class.new do
            include V2::FormInterface
            def attributes
              { name: 'John Doe' }
            end
          end
        end

        it 'validates properly' do
          expect(form.check).to be_a(form)
        end
      end

      context 'when the form does not implement attributes' do
        let(:form) do
          Class.new do
            include V2::FormInterface
          end
        end

        it 'raises a NotImplementedError on validation' do
          expect { form.check }.to raise_error(NotImplementedError, 'Requires implementation of attributes.')
        end
      end
    end
  end
end
