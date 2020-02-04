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
            :scope          => unique_scope
          })
        end

        after_create :much_slug_has_slug_generate_slugs
        after_update :much_slug_has_slug_generate_slugs
      end

      def much_slug_has_slug_registry
        @much_slug_has_slug_registry
      end
    end

    plugin_instance_methods do
      private

      def reset_slug(attribute = nil)
        MuchSlug.reset_slug(self, attribute)
      end

      def much_slug_has_slug_generate_slugs
        MuchSlug.has_slug_generate_slugs(self) do |attr_name, generated_slug|
          self.update_column(attr_name, generated_slug)
        end
      end
    end
  end
end
