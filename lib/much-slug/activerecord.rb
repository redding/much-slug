# frozen_string_literal: true

require "much-plugin"
require "much-slug"

module MuchSlug
  module ActiveRecord
    include MuchPlugin

    plugin_included do
      @much_slug_has_slug_registry = MuchSlug::HasSlugRegistry.new
    end

    plugin_class_methods do
      def has_slug(
            source:,
            attribute: nil,
            preprocessor: nil,
            separator: nil,
            allow_underscores: nil,
            skip_unique_validation: false,
            unique_scope: nil)
        registered_attribute =
          self.much_slug_has_slug_registry.register(
            attribute: attribute,
            source: source,
            preprocessor: preprocessor,
            separator: separator,
            allow_underscores: allow_underscores,
          )

        # since the slug isn't written until an after callback we can't always
        # validate presence of it
        validates_presence_of(registered_attribute, :on => :update)

        unless skip_unique_validation
          validates_uniqueness_of(registered_attribute, {
            :case_sensitive => true,
            :scope          => unique_scope,
            :allow_nil      => true,
            :allow_blank    => true
          })
        end

        after_create :much_slug_has_slug_update_slug_values
        after_update :much_slug_has_slug_update_slug_values

        registered_attribute
      end

      def much_slug_has_slug_registry
        @much_slug_has_slug_registry
      end
    end

    plugin_instance_methods do
      private

      def much_slug_has_slug_update_slug_values
        MuchSlug.has_slug_changed_slug_values(self) do |attribute, slug_value|
          self.send("#{attribute}=", slug_value)
          self.update_column(attribute, slug_value)
        end
      end
    end
  end
end
