require "assert"
require "much-slug"

module MuchSlug
  class UnitTests < Assert::Context
    desc "MuchSlug"
    setup do
      @module = MuchSlug
    end
    subject{ @module }

    should have_imeths :default_attribute, :default_preprocessor
    should have_imeths :default_separator

    should "know its default attribute, preprocessor and separator" do
      assert_equal :slug, subject.default_attribute
      assert_equal :to_s, subject.default_preprocessor
      assert_equal '-',   subject.default_separator
    end
  end
end
