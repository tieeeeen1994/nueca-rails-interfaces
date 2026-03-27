# frozen_string_literal: true

require 'active_model/railtie'

RSpec.describe NuecaRailsInterfaces::V3::FormInterface do
  let(:form_class) do
    Class.new do
      include NuecaRailsInterfaces::V3::FormInterface

      model :payment
    end
  end

  before do
    stub_const('Payment', Class.new do
      include ActiveModel::Model

      attr_accessor :amount

      validates :amount, numericality: { greater_than: 0 }, allow_nil: true

      def self.attribute_names
        ['amount']
      end

      def self.name
        'Payment'
      end
    end)
  end

  describe '#valid?' do
    context 'when model attributes are valid' do
      it 'returns true' do
        form = form_class.new(payment: { amount: 1 })
        expect(form.valid?).to be(true)
      end
    end

    context 'when model attributes are invalid' do
      it 'returns false' do
        form = form_class.new(payment: { amount: -1 })
        expect(form.valid?).to be(false)
      end

      it 'propagates model errors onto the form under the model name key' do
        form = form_class.new(payment: { amount: -1 })
        form.valid?
        expect(form.errors[:payment]).not_to be_empty
      end
    end

    context 'when the form has its own validations' do
      let(:form_with_validations) do
        Class.new do
          include NuecaRailsInterfaces::V3::FormInterface

          model :payment

          attr_accessor :user_email

          validates :user_email, presence: true

          def self.name
            'FormWithValidations'
          end
        end
      end

      it 'runs form-level validations alongside model validations' do
        form = form_with_validations.new(payment: { amount: 1 })
        expect(form.valid?).to be(false)
        expect(form.errors[:user_email]).not_to be_empty
      end

      it 'is valid when both form and model validations pass' do
        form = form_with_validations.new(
          payment: { amount: 1 },
          user_email: 'test@example.com'
        )
        expect(form.valid?).to be(true)
      end
    end
  end

  describe 'model instance reader' do
    it 'exposes the model instance via a method named after the model' do
      form = form_class.new(payment: { amount: 1 })
      expect(form.payment).to be_a(Payment)
      expect(form.payment.amount).to eq(1)
    end

    it 'responds to the model name method' do
      form = form_class.new(payment: { amount: 1 })
      expect(form).to respond_to(:payment)
    end
  end

  describe '#attributes' do
    it 'includes the model instance keyed by model name' do
      form = form_class.new(payment: { amount: 1 })
      expect(form.attributes[:payment]).to be_a(Payment)
    end

    it 'includes regular form attributes' do
      form_with_attr = Class.new do
        include NuecaRailsInterfaces::V3::FormInterface

        model :payment

        attr_accessor :reference_number
      end

      form = form_with_attr.new(payment: { amount: 1 }, reference_number: 'REF-001')
      expect(form.attributes[:reference_number]).to eq('REF-001')
    end

    context 'when attributes is overridden' do
      let(:custom_form) do
        Class.new do
          include NuecaRailsInterfaces::V3::FormInterface

          model :payment

          def attributes
            { custom: true }
          end
        end
      end

      it 'uses the developer-defined version' do
        form = custom_form.new(payment: { amount: 1 })
        expect(form.attributes).to eq(custom: true)
      end
    end
  end

  describe 'undeclared model keys' do
    it 'ignores hash-valued keys for models not listed in the macro' do
      form = form_class.new(order: { quantity: 5 })
      expect(form).not_to respond_to(:order)
    end
  end

  describe 'regular (non-model) keys' do
    it 'routes scalar keys to the form via ActiveModel attr_accessor' do
      form_with_attr = Class.new do
        include NuecaRailsInterfaces::V3::FormInterface

        attr_accessor :note
      end

      form = form_with_attr.new(note: 'hello')
      expect(form.note).to eq('hello')
    end
  end

  describe 'multiple model attribute groups' do
    before do
      stub_const('Order', Class.new do
        include ActiveModel::Model

        attr_accessor :quantity

        validates :quantity, numericality: { greater_than: 0 }, allow_nil: true

        def self.attribute_names
          ['quantity']
        end

        def self.name
          'Order'
        end
      end)
    end

    let(:multi_model_form) do
      Class.new do
        include NuecaRailsInterfaces::V3::FormInterface

        model :payment, :order
      end
    end

    it 'validates all model groups independently' do
      form = multi_model_form.new(
        payment: { amount: -1 },
        order: { quantity: -1 }
      )
      expect(form.valid?).to be(false)
      expect(form.errors[:payment]).not_to be_empty
      expect(form.errors[:order]).not_to be_empty
    end

    it 'exposes all model instances' do
      form = multi_model_form.new(
        payment: { amount: 1 },
        order: { quantity: 2 }
      )
      expect(form.payment).to be_a(Payment)
      expect(form.order).to be_a(Order)
    end
  end

  # ---------------------------------------------------------------------------
  describe '.flatten_errors' do
    let(:flat_form_class) do
      Class.new do
        include NuecaRailsInterfaces::V3::FormInterface

        model :payment
        flatten_errors
      end
    end

    it 'puts model errors on :base instead of the model name key' do
      form = flat_form_class.new(payment: { amount: -1 })
      form.valid?
      expect(form.errors[:base]).not_to be_empty
      expect(form.errors[:payment]).to be_empty
    end

    it 'does not affect forms that do not call flatten_errors' do
      form = form_class.new(payment: { amount: -1 })
      form.valid?
      expect(form.errors[:payment]).not_to be_empty
      expect(form.errors[:base]).to be_empty
    end
  end

  # ---------------------------------------------------------------------------
  describe '.check' do
    it 'instantiates, validates, and returns the form instance' do
      form = form_class.check(payment: { amount: 1 })
      expect(form).to be_a(form_class)
    end

    it 'returns an invalid form with errors when model validation fails' do
      form = form_class.check(payment: { amount: -1 })
      expect(form.errors[:payment]).not_to be_empty
    end
  end

  describe '.model macro' do
    let(:form_with_model_macro) do
      Class.new do
        include NuecaRailsInterfaces::V3::FormInterface

        model :payment

        def self.name
          'FormWithModelMacro'
        end
      end
    end

    it 'pre-instantiates the declared model even when no params are given' do
      form = form_with_model_macro.new
      expect(form.payment).to be_a(Payment)
    end

    it 'accepts params normally when provided' do
      form = form_with_model_macro.new(payment: { amount: 5 })
      expect(form.payment.amount).to eq(5)
    end

    it 'runs model validations when no params are given' do
      # Payment validates amount > 0 but allows nil; a blank form is valid.
      form = form_with_model_macro.new
      expect(form.valid?).to be(true)
    end

    it 'includes the pre-instantiated model in attributes' do
      form = form_with_model_macro.new
      expect(form.attributes[:payment]).to be_a(Payment)
    end

    it 'stores declared model names on the class' do
      expect(form_with_model_macro.declared_models).to include(:payment)
    end

    it 'does not duplicate models when params and macro both reference the same model' do
      form = form_with_model_macro.new(payment: { amount: 3 })
      expect(form.payment).to be_a(Payment)
      expect(form.payment.amount).to eq(3)
    end

    it 'silently discards fields inside _attributes that the model does not recognise' do
      form = form_with_model_macro.new(payment: { amount: 1, unknown_field: 'x' })
      expect(form.payment.amount).to eq(1)
      expect(form.payment).not_to respond_to(:unknown_field)
    end

    it 'accepts multiple model names in a single call' do
      stub_const('Order', Class.new do
        include ActiveModel::Model

        attr_accessor :quantity

        def self.attribute_names = ['quantity']
        def self.name = 'Order'
      end)

      klass = Class.new do
        include NuecaRailsInterfaces::V3::FormInterface

        model :payment, :order
      end

      expect(klass.declared_models).to contain_exactly(:payment, :order)
    end
  end
end
