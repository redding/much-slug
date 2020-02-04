require "assert"
require "much-slug/activerecord"

require "much-plugin"
require "ardb/record_spy"

module MuchSlug::ActiveRecord
  class UnitTests < Assert::Context
    desc "MuchSlug::ActiveRecord"
    setup do
      source_attribute = @source_attribute = Factory.string.to_sym
      slug_attribute   = @slug_attribute   = Factory.string
      @record_class = Ardb::RecordSpy.new do
        include MuchSlug::ActiveRecord
        attr_accessor source_attribute, slug_attribute, MuchSlug.default_attribute
        attr_reader :slug_db_column_updates

        def update_column(*args)
          @slug_db_column_updates ||= []
          @slug_db_column_updates << args
        end
      end

      @has_slug_attribute = Factory.string
      @has_slug_preprocessor = :downcase
      @has_slug_separator = Factory.non_word_chars.sample
      @has_slug_allow_underscores = Factory.boolean

      Assert.stub_tap(@record_class.much_slug_has_slug_registry, :register) { |**kargs|
        @register_called_with = kargs
      }
    end
    subject{ @record_class }

    should have_imeths :has_slug
    should have_imeths :much_slug_has_slug_registry

    should "not have any has_slug registry entries by default" do
      assert_kind_of MuchSlug::HasSlugRegistry, subject.much_slug_has_slug_registry
      assert_empty subject.much_slug_has_slug_registry
    end

    should "register a new has_slug entry using `has_slug`" do
      subject.has_slug(
        source: @source_attribute,
        attribute: @has_slug_attribute,
        preprocessor: @has_slug_preprocessor,
        separator: @has_slug_separator,
        allow_underscores: @has_slug_allow_underscores
      )

      exp_kargs = {
        attribute: @has_slug_attribute,
        source: @source_attribute,
        preprocessor: @has_slug_preprocessor,
        separator: @has_slug_separator,
        allow_underscores: @has_slug_allow_underscores
      }
      assert_equal exp_kargs, @register_called_with
    end

    should "add validations using `has_slug`" do
      subject.has_slug(
        source: @source_attribute,
        attribute: @has_slug_attribute
      )
      exp_attr_name = @has_slug_attribute

      validation = subject.validations.find{ |v| v.type == :presence }
      assert_not_nil validation
      assert_equal [exp_attr_name], validation.columns
      assert_equal :update, validation.options[:on]

      validation = subject.validations.find{ |v| v.type == :uniqueness }
      assert_not_nil validation
      assert_equal [exp_attr_name], validation.columns
      assert_equal true, validation.options[:case_sensitive]
      assert_nil validation.options[:scope]
    end

    should "not add a unique validation if skipping unique validation" do
      subject.has_slug(
        source: @source_attribute,
        attribute: @has_slug_attribute,
        skip_unique_validation: true
      )

      validation = subject.validations.find{ |v| v.type == :uniqueness }
      assert_nil validation
    end

    should "allow customizing its validations using `has_slug`" do
      unique_scope = Factory.string.to_sym
      subject.has_slug(
        source: @source_attribute,
        attribute: @has_slug_attribute,
        unique_scope: unique_scope
      )

      validation = subject.validations.find{ |v| v.type == :uniqueness }
      assert_not_nil validation
      assert_equal unique_scope, validation.options[:scope]
    end

    should "add callbacks using `has_slug`" do
      subject.has_slug(source: @source_attribute)

      callback = subject.callbacks.find{ |v| v.type == :after_create }
      assert_not_nil callback
      assert_equal [:much_slug_has_slug_generate_slugs], callback.args

      callback = subject.callbacks.find{ |v| v.type == :after_update }
      assert_not_nil callback
      assert_equal [:much_slug_has_slug_generate_slugs], callback.args
    end

    should "raise an argument error if `has_slug` isn't passed a source" do
      assert_raises(ArgumentError){ subject.has_slug }
    end
  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @preprocessor      = [:downcase, :upcase, :capitalize].sample
      @separator         = Factory.non_word_chars.sample
      @allow_underscores = Factory.boolean

      @record_class.has_slug(source: @source_attribute)
      @record_class.has_slug(
        source:            @source_attribute,
        attribute:         @slug_attribute,
        preprocessor:      @preprocessor,
        separator:         @separator,
        allow_underscores: @allow_underscores
      )

      @record = @record_class.new

      # create a string that has mixed case and an underscore so we can test
      # that it uses the preprocessor and allow underscores options when
      # generating a slug
      @source_value = "#{Factory.string.downcase}_#{Factory.string.upcase}"
      @record.send("#{@source_attribute}=", @source_value)

      @exp_default_slug =
        MuchSlug::Slug.new(
          @source_value,
          preprocessor:      MuchSlug.default_preprocessor.to_proc,
          separator:         MuchSlug.default_separator,
          allow_underscores: true
        )
      @exp_custom_slug =
        MuchSlug::Slug.new(
          @source_value,
          preprocessor:      @preprocessor.to_proc,
          separator:         @separator,
          allow_underscores: @allow_underscores
        )
    end
    subject{ @record }

    should "reset its slug using `reset_slug`" do
      # reset the default attribute
      subject.send("#{MuchSlug.default_attribute}=", Factory.slug)
      assert_not_nil subject.send(MuchSlug.default_attribute)
      subject.instance_eval{ reset_slug }
      assert_nil subject.send(MuchSlug.default_attribute)

      # reset a custom attribute
      subject.send("#{@slug_attribute}=", Factory.slug)
      assert_not_nil subject.send(@slug_attribute)
      sa = @slug_attribute
      subject.instance_eval{ reset_slug(sa) }
      assert_nil subject.send(@slug_attribute)
    end

    should "default its slug attribute" do
      subject.instance_eval{ much_slug_has_slug_generate_slugs }
      assert_equal 2, subject.slug_db_column_updates.size

      exp = @exp_default_slug
      assert_equal exp, subject.send(MuchSlug.default_attribute)
      assert_includes [MuchSlug.default_attribute, exp], subject.slug_db_column_updates

      exp = @exp_custom_slug
      assert_equal exp, subject.send(@slug_attribute)
      assert_includes [@slug_attribute, exp], subject.slug_db_column_updates
    end

    should "not set its slug if it hasn't changed" do
      @record.send("#{MuchSlug.default_attribute}=", @exp_default_slug)
      @record.send("#{@slug_attribute}=",   @exp_custom_slug)

      subject.instance_eval{ much_slug_has_slug_generate_slugs }
      assert_nil subject.slug_db_column_updates
    end

    should "slug its slug attribute value if set" do
      @record.send("#{@slug_attribute}=", @source_value)
      # change the source attr to some random value, to avoid a false positive
      @record.send("#{@source_attribute}=", Factory.string)
      subject.instance_eval{ much_slug_has_slug_generate_slugs }

      exp = @exp_custom_slug
      assert_equal exp, subject.send(@slug_attribute)
      assert_includes [@slug_attribute, exp], subject.slug_db_column_updates
    end

    should "slug its source even if its already a valid slug" do
      slug_source = Factory.slug
      @record.send("#{@source_attribute}=", slug_source)
      # ensure the preprocessor doesn't change our source
      Assert.stub(slug_source, @preprocessor){ slug_source }

      subject.instance_eval{ much_slug_has_slug_generate_slugs }

      exp =
        MuchSlug::Slug.new(
          slug_source,
          preprocessor:      @preprocessor.to_proc,
          separator:         @separator,
          allow_underscores: @allow_underscores
        )
      assert_equal exp, subject.send(@slug_attribute)
      assert_includes [@slug_attribute, exp], subject.slug_db_column_updates
    end
  end
end
