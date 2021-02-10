# frozen_string_literal: true

require "assert"
require "much-slug/activerecord"

require "ardb/record_spy"

module MuchSlug::ActiveRecord
  class UnitTests < Assert::Context
    desc "MuchSlug::ActiveRecord"
    subject{ unit_module }

    let(:unit_module){ MuchSlug::ActiveRecord }
  end

  class ReceiverTests < UnitTests
    desc "receiver"
    subject{ receiver_class }

    setup do
      Assert.stub_tap_on_call(
        receiver_class.much_slug_has_slug_registry,
        :register,
      ) do |_, call|
        @register_call = call
      end
    end

    let(:receiver_class) do
      attr_source_attribute = source_attribute
      attr_slug_attribute   = slug_attribute

      Ardb::RecordSpy.new do
        include MuchSlug::ActiveRecord
        attr_accessor attr_source_attribute, attr_slug_attribute
        attr_accessor MuchSlug.default_attribute
        attr_reader :slug_db_column_updates
        attr_reader :save_called, :save_bang_called

        def update_column(*args)
          @slug_db_column_updates ||= []
          @slug_db_column_updates << args
        end
      end
    end
    let(:source_attribute){ Factory.symbol }
    let(:slug_attribute){ Factory.string }

    let(:has_slug_attribute){ Factory.string }
    let(:has_slug_preprocessor){ :downcase }
    let(:has_slug_separator){ Factory.non_word_chars.sample }
    let(:has_slug_allow_underscores){ Factory.boolean }

    should have_imeths :has_slug
    should have_imeths :much_slug_has_slug_registry

    should "not have any has_slug registry entries by default" do
      assert_that(subject.much_slug_has_slug_registry)
        .is_an_instance_of(MuchSlug::HasSlugRegistry)
      assert_that(subject.much_slug_has_slug_registry.empty?).is_true
    end

    should "register a new has_slug entry using `has_slug`" do
      subject.has_slug(
        source:            source_attribute,
        attribute:         has_slug_attribute,
        preprocessor:      has_slug_preprocessor,
        separator:         has_slug_separator,
        allow_underscores: has_slug_allow_underscores,
      )

      assert_that(@register_call.kargs)
        .equals(
          attribute:         has_slug_attribute,
          source:            source_attribute,
          preprocessor:      has_slug_preprocessor,
          separator:         has_slug_separator,
          allow_underscores: has_slug_allow_underscores,
        )
    end

    should "add validations using `has_slug`" do
      subject.has_slug(
        source:    source_attribute,
        attribute: has_slug_attribute,
      )

      validation = subject.validations.find{ |v| v.type == :presence }
      assert_that(validation).is_not_nil
      assert_that(validation.columns).equals([has_slug_attribute])
      assert_that(validation.options[:on]).equals(:update)

      validation = subject.validations.find{ |v| v.type == :uniqueness }
      assert_that(validation).is_not_nil
      assert_that(validation.columns).equals([has_slug_attribute])
      assert_that(validation.options[:case_sensitive]).is_true
      assert_that(validation.options[:scope]).is_nil
      assert_that(validation.options[:allow_nil]).is_true
      assert_that(validation.options[:allow_blank]).is_true
    end

    should "not add a unique validation if skipping unique validation" do
      subject.has_slug(
        source:                 source_attribute,
        attribute:              has_slug_attribute,
        skip_unique_validation: true,
      )

      validation = subject.validations.find{ |v| v.type == :uniqueness }
      assert_that(validation).is_nil
    end

    should "allow customizing its validations using `has_slug`" do
      unique_scope = Factory.string.to_sym
      subject.has_slug(
        source:       source_attribute,
        attribute:    has_slug_attribute,
        unique_scope: unique_scope,
      )

      validation = subject.validations.find{ |v| v.type == :uniqueness }
      assert_that(validation).is_not_nil
      assert_that(validation.options[:scope]).equals(unique_scope)
    end

    should "add callbacks using `has_slug`" do
      subject.has_slug(source: source_attribute)

      callback = subject.callbacks.find{ |v| v.type == :after_create }
      assert_that(callback).is_not_nil
      assert_that(callback.args)
        .equals([:much_slug_has_slug_update_slug_values])

      callback = subject.callbacks.find{ |v| v.type == :after_update }
      assert_that(callback).is_not_nil
      assert_that(callback.args)
        .equals([:much_slug_has_slug_update_slug_values])
    end

    should "raise an argument error if `has_slug` isn't passed a source" do
      assert_that{
        subject.has_slug
      }.raises(ArgumentError)
    end
  end

  class ReceiverInheritedTests < ReceiverTests
    desc "is inherited from"

    setup do
      subject.has_slug(source: :name)

      Assert.stub_tap(MuchSlug::HasSlugRegistry, :new) do |has_slug_registry|
        Assert.stub_on_call(has_slug_registry, :copy_from) do |call|
          @has_slug_registry_copy_from_call = call
        end
      end
    end

    should "copy its MuchSlug::HasSlugRegistry to the child class" do
      Class.new(receiver_class)
      assert_that(@has_slug_registry_copy_from_call.args)
        .equals([subject.much_slug_has_slug_registry])
    end
  end

  class ReceiverInitTests < ReceiverTests
    desc "when init"
    subject{ receiver }

    setup do
      registered_default_attribute
      registered_custom_attribute

      subject.public_send("#{source_attribute}=", source_value)
    end

    let(:receiver){ receiver_class.new }

    let(:registered_default_attribute) do
      receiver_class.has_slug(source: source_attribute)
    end
    let(:registered_custom_attribute) do
      block_source_attribute = source_attribute

      receiver_class.has_slug(
        source:            ->{ public_send(block_source_attribute) },
        attribute:         slug_attribute,
        preprocessor:      preprocessor,
        separator:         separator,
        allow_underscores: allow_underscores,
      )
    end
    let(:preprocessor){ [:downcase, :upcase, :capitalize].sample }
    let(:separator){ Factory.non_word_chars.sample }
    let(:allow_underscores){ Factory.boolean }

    # create a string that has mixed case and an underscore so we can test
    # that it uses the preprocessor and allow underscores options when
    # generating a slug
    let(:source_value) do
      "#{Factory.string.downcase}_#{Factory.string.upcase}"
    end

    let(:exp_default_slug) do
      MuchSlug::Slug.new(
        source_value,
        preprocessor:      MuchSlug.default_preprocessor.to_proc,
        separator:         MuchSlug.default_separator,
        allow_underscores: false,
      )
    end
    let(:exp_custom_slug) do
      MuchSlug::Slug.new(
        source_value,
        preprocessor:      preprocessor.to_proc,
        separator:         separator,
        allow_underscores: allow_underscores,
      )
    end

    should "default its slug attribute" do
      assert_that(registered_default_attribute)
        .equals(MuchSlug.default_attribute)
      assert_that(registered_custom_attribute).equals(slug_attribute)

      subject.instance_eval{ much_slug_has_slug_update_slug_values }
      assert_that(subject.slug_db_column_updates.size).equals(2)

      assert_that(subject.public_send(MuchSlug.default_attribute))
        .equals(exp_default_slug)
      assert_that(subject.slug_db_column_updates)
        .includes([MuchSlug.default_attribute, exp_default_slug])

      assert_that(subject.public_send(slug_attribute)).equals(exp_custom_slug)
      assert_that(subject.slug_db_column_updates)
        .includes([slug_attribute, exp_custom_slug])
    end

    should "not set its slug if it hasn't changed" do
      subject.public_send("#{MuchSlug.default_attribute}=", exp_default_slug)
      subject.public_send("#{slug_attribute}=", exp_custom_slug)

      subject.instance_eval{ much_slug_has_slug_update_slug_values }
      assert_that(subject.slug_db_column_updates).is_nil
    end

    should "slug its source even if its already a valid slug" do
      slug_source = Factory.slug
      subject.public_send("#{source_attribute}=", slug_source)
      # ensure the preprocessor doesn't change our source
      Assert.stub(slug_source, preprocessor){ slug_source }

      subject.instance_eval{ much_slug_has_slug_update_slug_values }

      exp =
        MuchSlug::Slug.new(
          slug_source,
          preprocessor:      preprocessor.to_proc,
          separator:         separator,
          allow_underscores: allow_underscores,
        )
      assert_that(subject.public_send(slug_attribute)).equals(exp)
      assert_that(subject.slug_db_column_updates)
        .includes([slug_attribute, exp])
    end

    should "manually update slugs" do
      result = MuchSlug.update_slugs(subject)
      assert_that(result).is_true
      assert_that(subject.slug_db_column_updates.size).equals(2)

      assert_that(subject.public_send(MuchSlug.default_attribute))
        .equals(exp_default_slug)
      assert_that(subject.slug_db_column_updates)
        .includes([MuchSlug.default_attribute, exp_default_slug])

      assert_that(subject.public_send(slug_attribute)).equals(exp_custom_slug)
      assert_that(subject.slug_db_column_updates)
        .includes([slug_attribute, exp_custom_slug])
    end
  end
end
