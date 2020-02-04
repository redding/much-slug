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
    should have_imeths :default_separator, :default_allow_underscores
    should have_imeths :update_slugs, :update_slugs!

    should "know its default settings" do
      assert_equal "slug", subject.default_attribute
      assert_equal :to_s, subject.default_preprocessor
      assert_equal "-", subject.default_separator
      assert_equal true, subject.default_allow_underscores
    end
  end
end
