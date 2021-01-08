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

    should have_imeths :register

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
