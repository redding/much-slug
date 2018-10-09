require "much-plugin"
require "much-slug"

module MuchSlug

  module ActiveRecord
    include MuchPlugin

    plugin_included do
      extend ClassMethods
      include InstanceMethods

      @much_slug_has_slug_configs = MuchSlug::Configs.new
    end

    module ClassMethods

      def has_slug(options = nil)
        options ||= {}
        attribute = MuchSlug.set_has_slug(@much_slug_has_slug_configs, options)

        # since the slug isn't written until an after callback we can't always
        # validate presence of it
        validates_presence_of(attribute, :on => :update)

        if options[:skip_unique_validation] != true
          validates_uniqueness_of(attribute, {
            :case_sensitive => true,
            :scope          => options[:unique_scope]
          })
        end

        after_create :much_slug_has_slug_generate_slugs
        after_update :much_slug_has_slug_generate_slugs
      end

      def much_slug_has_slug_configs
        @much_slug_has_slug_configs
      end

    end

    module InstanceMethods

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
