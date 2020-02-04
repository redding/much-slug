require "assert"
require "much-slug/has_slug_registry"

class MuchSlug::HasSlugRegistry
  class UnitTests < Assert::Context
    desc "MuchSlug::HasSlugRegistry"
    setup do
      @class = MuchSlug::HasSlugRegistry
    end
    subject{ @class }

    should "subclass Hash" do
      assert subject < ::Hash
    end
  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @attribute = Factory.string.to_sym
      @source = :to_s
      @preprocessor = :downcase
      @separator = "|"
      @allow_underscores = Factory.boolean

      @registry = @class.new
    end
    subject{ @registry }

    should have_imeths :register

    should "default empty entries for unregisterd attributes" do
      entry = subject[Factory.string]
      assert_kind_of @class::Entry, entry
    end

    should "register new entries" do
      registered_attribute =
        subject.register(
          attribute: @attribute,
          source: @source,
          preprocessor: @preprocessor,
          separator: @separator,
          allow_underscores: @allow_underscores
        )

      assert_equal @attribute.to_s, registered_attribute

      entry = subject[registered_attribute]
      assert_kind_of @class::Entry, entry
      assert_equal @source.to_proc, entry.source_proc
      assert_equal @preprocessor.to_proc, entry.preprocessor_proc
      assert_equal @separator, entry.separator
      assert_equal @allow_underscores, entry.allow_underscores

      assert_same entry, subject[registered_attribute]
    end

    should "default registered settings if none are provided" do
      registered_attribute =
        subject.register(
          attribute: nil,
          source: @source,
          preprocessor: nil,
          separator: nil,
          allow_underscores: nil
        )

      assert_equal MuchSlug.default_attribute.to_s, registered_attribute

      entry = subject[registered_attribute]
      assert_equal MuchSlug.default_preprocessor.to_proc, entry.preprocessor_proc
      assert_equal MuchSlug.default_separator, entry.separator
      assert_equal MuchSlug.default_allow_underscores, entry.allow_underscores
    end
  end

  class EntryUnitTests < UnitTests
    desc "Entry"
    setup do
      @entry_class = MuchSlug::HasSlugRegistry::Entry
    end
    subject{ @entry_class }
  end

  class EntryInitTests < EntryUnitTests
    desc "when init"
    setup do
      @entry = @entry_class.new
    end
    subject{ @entry }

    should have_accessors :source_proc, :preprocessor_proc, :separator, :allow_underscores
  end
end
