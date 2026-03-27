# frozen_string_literal: true

module NuecaRailsInterfaces
  module V3
    # V3 Form Interface delegates model validation to the actual model instances
    # rather than reimplementing model validations inside the form.
    #
    # Models managed by the form are declared explicitly with the `model` macro.
    # Their attributes arrive as a nested hash keyed by the model name, which is
    # what `fields_for :school_year, f.object.school_year` produces in the view —
    # e.g. `school_year: { name: "..." }`.  This maps directly to:
    # `params.expect(my_form: [{ school_year: [:name] }, :other_field])`
    #
    # Only models listed in the `model` macro are processed; any key whose name
    # matches a declared model and whose value is a Hash (or Parameters) is treated
    # as model attributes.  Everything else is treated as a regular form attribute.
    # Fields inside a model hash that the model does not recognise are silently
    # discarded.
    #
    # Custom form-level fields (fields that belong to the form, not to any model)
    # are declared as plain `attr_accessor`s on the form class, just like any other
    # ActiveModel attribute.
    #
    # Calling `valid?` on the form runs form-level validations first, then calls
    # `valid?` on each model instance and propagates any model errors onto the form
    # under the model name key (e.g. `errors[:payment]`).  `fields_for :payment`
    # in the view binds to `form.payment` and reads that object's own errors for
    # per-field error rendering, so both levels work naturally together.
    #
    # The `attributes` method returns a hash of model instances merged with any
    # regular form attributes.  It can be overridden in the form class.
    module FormInterface
      # Prepended so these methods precede ActiveModel::Model's versions in the
      # method resolution order.  When `base.include(ActiveModel::Model)` is called
      # inside the `included` hook, ActiveModel ends up earlier in the ancestor chain,
      # which would otherwise cause ActiveModel::API#initialize to intercept `new`
      # before our param-splitting logic runs.
      module InstanceMethods
        def initialize(options = {})
          @model_instances = {}
          @regular_attributes = extract_regular_attributes(options)

          # Pre-instantiate declared models that were not present in the params
          # (e.g. the form is used in a `new` action with no input yet).
          (self.class.declared_models - @model_instances.keys).each do |model_sym|
            @model_instances[model_sym] = model_sym.to_s.camelize.constantize.new
          end

          super(**@regular_attributes)
        end

        def valid?(context = nil)
          # Clears errors and runs form-level validations.
          super

          error_key = self.class.flatten_errors? ? :base : nil

          @model_instances.each do |model_name, model_instance|
            next if model_instance.valid?

            model_instance.errors.each do |error|
              errors.add(error_key || model_name, error.full_message)
            end
          end

          errors.empty?
        end

        def method_missing(name, *args, &)
          return @model_instances[name] if @model_instances.key?(name)

          super
        end

        def respond_to_missing?(name, include_private = false)
          @model_instances.key?(name) || super
        end

        private

        # Builds the model instance from the given attributes hash, assigning only
        # fields the model recognises.  Unknown fields are silently discarded.
        # `attrs` may be a plain Hash or ActionController::Parameters — both are
        # normalised to a plain Hash before processing; field whitelisting via
        # Splits options into model instances and regular form attributes.
        # Hash-valued keys matching a declared model are built into model instances.
        # Hash-valued keys for undeclared models are silently discarded.
        # All other (scalar) keys are returned as regular attributes for super.
        def extract_regular_attributes(options)
          regular_attrs = {}
          options.each do |key, value|
            if self.class.declared_models.include?(key.to_sym) && value.respond_to?(:each_pair)
              build_model_instance(key.to_sym, value)
            elsif !value.respond_to?(:each_pair)
              regular_attrs[key] = value
            end
          end
          regular_attrs
        end

        # `model_field?` provides the equivalent of strong-param filtering here.
        def build_model_instance(model_name, attrs)
          model_class = model_name.to_s.camelize.constantize
          attrs_hash = attrs.respond_to?(:to_unsafe_h) ? attrs.to_unsafe_h : attrs.to_h
          model_attrs = attrs_hash.each_with_object({}) do |(field, value), hash|
            hash[field.to_sym] = value if model_field?(model_class, field.to_s)
          end
          @model_instances[model_name] = model_class.new(**model_attrs)
        end

        # A field belongs to the model if the model class declares it via
        # `attribute_names` (ActiveRecord) or has an assignment method
        # (ActiveModel attr_accessor, etc.).
        def model_field?(model_class, field_name)
          (model_class.respond_to?(:attribute_names) && model_class.attribute_names.include?(field_name)) ||
            model_class.method_defined?("#{field_name}=")
        end
      end

      class << self
        def included(base)
          base.include(ActiveModel::Model)
          base.prepend(InstanceMethods)
          define_class_macros(base)
        end

        private

        def define_class_macros(base)
          base.instance_variable_set(:@declared_models, [])
          base.instance_variable_set(:@flatten_errors, false)

          base.define_singleton_method(:flatten_errors) { @flatten_errors = true }
          base.define_singleton_method(:flatten_errors?) { @flatten_errors }

          # Declares one or more models managed by this form.  Each symbol must be
          # the underscored model name (e.g. `model :payment`, `model :school_year`).
          # Only declared models are processed from params.  Declared models are always instantiated
          # (with blank attributes) even when their params are absent.
          base.define_singleton_method(:model) do |*model_names|
            model_names.each { |n| @declared_models << n.to_sym }
          end

          base.define_singleton_method(:declared_models) { @declared_models }

          base.define_singleton_method(:check) do |*arguments|
            instance = NuecaRailsInterfaces::Util.process_class_arguments(self, *arguments)
            instance.valid?
            instance
          end
        end
      end

      # Returns a merged hash of model instances and regular form attributes.
      # Defined here (included, not prepended) so that a form class can override it
      # by defining its own `attributes` method — the class-level definition is found
      # first in the MRO, falling back to this default when no override exists.
      def attributes
        result = {}
        result.merge!(@model_instances)
        result.merge!(@regular_attributes.transform_keys(&:to_sym))
        result.with_indifferent_access
      end
    end
  end
end
