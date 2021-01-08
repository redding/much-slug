# frozen_string_literal: true

require "assert"
require "much-slug"

module MuchSlug
  class UnitTests < Assert::Context
    desc "MuchSlug"
    subject{ MuchSlug }

    should have_imeths :default_attribute, :default_preprocessor
    should have_imeths :default_separator, :default_allow_underscores
    should have_imeths :update_slugs

    should "know its default settings" do
      assert_that(subject.default_attribute).equals("slug")
      assert_that(subject.default_preprocessor).equals(:to_s)
      assert_that(subject.default_separator).equals("-")
      assert_that(subject.default_allow_underscores).equals(false)
    end
  end
end
