# frozen_string_literal: true

require "assert"
require "much-slug/slug"

module MuchSlug::Slug
  class UnitTests < Assert::Context
    desc "MuchSlug::Slug"
    subject{ unit_module }

    let(:unit_module){ MuchSlug::Slug }

    let(:no_op_pp){ proc{ |slug| slug } }
    let(:separator){ "-" }
    let(:kargs) do
      {
        preprocessor: no_op_pp,
        separator: separator,
      }
    end

    should have_imeths :new

    should "always dup the given string" do
      string = Factory.string
      assert_that(subject.new(string, **kargs)).is_not(string)
    end

    should "not change strings that are made up of valid chars" do
      string = Factory.string
      assert_that(subject.new(string, **kargs)).equals(string)

      string = "#{Factory.string}#{separator}#{Factory.string.upcase}"
      assert_that(subject.new(string, **kargs)).equals(string)
    end

    should "turn invalid chars into a separator" do
      string =
        Array
          .new(Factory.integer(3)){
            "#{Factory.string(3)}#{Factory.non_word_chars.sample}"\
            "#{Factory.string(3)}"
          }
          .join(Factory.non_word_chars.sample)
      assert_that(subject.new(string, **kargs))
        .equals(string.gsub(/[^\w]+/, separator))
    end

    should "allow passing a custom preprocessor proc" do
      string       = "#{Factory.string}#{separator}#{Factory.string.upcase}"
      custom_kargs = kargs.merge(preprocessor: :downcase.to_proc)
      assert_that(subject.new(string, **custom_kargs)).equals(string.downcase)

      preprocessor = proc{ |s| s.gsub(/[A-Z]/, "a") }
      custom_kargs = kargs.merge(preprocessor: preprocessor)
      assert_that(subject.new(string, **custom_kargs))
        .equals(preprocessor.call(string))
    end

    should "allow passing a custom separator" do
      separator    = Factory.non_word_chars.sample
      invalid_char = (Factory.non_word_chars - [separator]).sample

      string = "#{Factory.string}#{invalid_char}#{Factory.string}"
      assert_that(subject.new(string, **kargs.merge(separator: separator)))
        .equals(string.gsub(/[^\w]+/, separator))

      # it won"t change the separator in the strings
      string = "#{Factory.string}#{separator}#{Factory.string}"
      assert_that(subject.new(string, **kargs.merge(separator: separator)))
        .equals(string)

      # it will change the default separator now
      string = "#{Factory.string}#{separator}#{Factory.string}"
      assert_that(subject.new(string, **kargs.merge(separator: separator)))
        .equals(string.gsub(separator, separator))
    end

    should "change underscores into its separator if not allowed" do
      string = "#{Factory.string}#{separator}#{Factory.string}"
      assert_that(subject.new(string, **kargs)).equals(string)

      custom_kargs = kargs.merge(allow_underscores: false)
      assert_that(subject.new(string, **custom_kargs))
        .equals(string.gsub("_", separator))

      custom_kargs = kargs.merge(allow_underscores: true)
      assert_that(subject.new(string, **custom_kargs)).equals(string)
    end

    should "not allow multiple separators in a row" do
      string = "#{Factory.string}#{separator}#{separator}#{Factory.string}"
      assert_that(subject.new(string, **kargs))
        .equals(string.gsub(/-{2,}/, separator))

      # remove separators that were added from changing invalid chars
      invalid_chars =
        Array
          .new(Factory.integer(3) + 1){
            Factory.non_word_chars.sample
          }
          .join
      string = "#{Factory.string}#{invalid_chars}#{Factory.string}"
      assert_that(subject.new(string, **kargs))
        .equals(string.gsub(/[^\w]+/, separator))
    end

    should "remove leading and trailing separators" do
      string = "-#{Factory.string}#{separator}#{Factory.string}-"
      assert_that(subject.new(string, **kargs)).equals(string[1..-2])

      # remove separators that were added from changing invalid chars
      invalid_char = Factory.non_word_chars.sample
      string =
        "#{invalid_char}#{Factory.string}#{separator}"\
        "#{Factory.string}#{invalid_char}"
      assert_that(subject.new(string, **kargs)).equals(string[1..-2])
    end
  end
end
