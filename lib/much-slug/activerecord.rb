# frozen_string_literal: true

require "much-mixin"
require "much-slug"

module MuchSlug; end

module MuchSlug::ActiveRecord
  include MuchMixin

  mixin_class_methods do
    def much_slug_has_slug_registry
      @much_slug_has_slug_registry ||= MuchSlug::HasSlugRegistry.new
    end

    def has_slug(
          source:,
          attribute:              nil,
          preprocessor:           nil,
          separator:              nil,
          allow_underscores:      nil,
          skip_unique_validation: false,
          unique_scope:           nil)
      registered_attribute =
        much_slug_has_slug_registry.register(
          attribute:         attribute,
          source:            source,
          preprocessor:      preprocessor,
          separator:         separator,
          allow_underscores: allow_underscores,
        )

      # since the slug isn't written until an after callback we can't always
      # validate presence of it
      validates_presence_of(registered_attribute, on: :update)

      unless skip_unique_validation
        validates_uniqueness_of(
          registered_attribute,
          case_sensitive: true,
          scope:          unique_scope,
          allow_nil:      true,
          allow_blank:    true,
        )
      end

      after_create :much_slug_has_slug_update_slug_values
      after_update :much_slug_has_slug_update_slug_values

      registered_attribute
    end
  end

  mixin_instance_methods do
    private

    def much_slug_has_slug_update_slug_values
      MuchSlug.has_slug_changed_slug_values(self) do |attribute, slug_value|
        public_send("#{attribute}=", slug_value)
        update_column(attribute, slug_value)
      end
    end
  end
end
