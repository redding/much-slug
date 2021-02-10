# frozen_string_literal: true

require "assert"
require "much-slug/has_slug_registry"

class MuchSlug::HasSlugRegistry
  class UnitTests < Assert::Context
    desc "MuchSlug::HasSlugRegistry"
    subject{ unit_class }

    let(:unit_class){ MuchSlug::HasSlugRegistry }

    should "be a Hash" do
      assert_that(subject < ::Hash).is_true
    end
  end

  class InitTests < UnitTests
    desc "when init"
    subject{ unit_class.new }

    let(:attribute){ Factory.symbol }
    let(:source){ :to_s }
    let(:preprocessor){ :downcase }
    let(:separator){ "|" }
    let(:allow_underscores){ Factory.boolean }

    should have_imeths :register, :copy_from

    should "default empty entries for unregisterd attributes" do
      assert_that(subject[Factory.string]).is_an_instance_of(unit_class::Entry)
    end

    should "register new entries" do
      registered_attribute =
        subject.register(
          attribute:         attribute,
          source:            source,
          preprocessor:      preprocessor,
          separator:         separator,
          allow_underscores: allow_underscores,
        )

      assert_that(registered_attribute).equals(attribute.to_s)

      entry = subject[registered_attribute]
      assert_that(entry).is_an_instance_of(unit_class::Entry)
      assert_that(entry.source_proc).equals(source.to_proc)
      assert_that(entry.preprocessor_proc).equals(preprocessor.to_proc)
      assert_that(entry.separator).equals(separator)
      assert_that(entry.allow_underscores).equals(allow_underscores)

      assert_that(subject[registered_attribute]).is(entry)
    end

    should "default registered settings if none are provided" do
      registered_attribute =
        subject.register(
          attribute:         nil,
          source:            source,
          preprocessor:      nil,
          separator:         nil,
          allow_underscores: nil,
        )

      assert_that(registered_attribute).equals(MuchSlug.default_attribute.to_s)

      entry = subject[registered_attribute]
      assert_that(entry.preprocessor_proc)
        .equals(MuchSlug.default_preprocessor.to_proc)
      assert_that(entry.separator).equals(MuchSlug.default_separator)
      assert_that(entry.allow_underscores)
        .equals(MuchSlug.default_allow_underscores)
    end
  end

  class CopyFromTests < InitTests
    desc "#copy_from"

    setup do
      parent_has_slug_registry.register(
        attribute: attribute,
        source: source,
        preprocessor: nil,
        separator: nil,
        allow_underscores: nil,
      )
      parent_has_slug_registry.register(
        attribute: other_attribute,
        source: other_source,
        preprocessor: nil,
        separator: nil,
        allow_underscores: nil,
      )
    end

    let(:other_attribute){ Factory.symbol }
    let(:other_source){ :to_s }

    let(:parent_has_slug_registry){ unit_class.new }

    should "copy entries from the passed MuchSlug::HasSlugRegistry" do
      subject.copy_from(parent_has_slug_registry)

      assert_that(subject[attribute])
        .equals(parent_has_slug_registry[attribute])
      assert_that(subject[attribute])
        .is_not(parent_has_slug_registry[attribute])
      assert_that(subject[other_attribute])
        .equals(parent_has_slug_registry[other_attribute])
      assert_that(subject[other_attribute])
        .is_not(parent_has_slug_registry[other_attribute])
    end
  end

  class EntryUnitTests < UnitTests
    desc "Entry"

    let(:entry_class){ MuchSlug::HasSlugRegistry::Entry }
  end

  class EntryInitTests < EntryUnitTests
    desc "when init"
    subject{ entry_class.new }

    should have_accessors :source_proc, :preprocessor_proc, :separator
    should have_accessors :allow_underscores
  end
end
