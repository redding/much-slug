require "assert"
require "much-slug/slug"

module MuchSlug::Slug
  class UnitTests < Assert::Context
    desc "MuchSlug::Slug"
    setup do
      @no_op_pp = proc{ |slug| slug }
      @args = {
        :preprocessor => @no_op_pp,
        :separator    => "-"
      }

      @module = MuchSlug::Slug
    end
    subject{ @module }

    should have_imeths :new

    should "always dup the given string" do
      string = Factory.string
      assert_not_same string, subject.new(string, @args)
    end

    should "not change strings that are made up of valid chars" do
      string = Factory.string
      assert_equal string, subject.new(string, @args)

      string = "#{Factory.string}-#{Factory.string.upcase}"
      assert_equal string, subject.new(string, @args)
    end

    should "turn invalid chars into a separator" do
      string = Factory.integer(3).times.map do
        "#{Factory.string(3)}#{Factory.non_word_chars.sample}#{Factory.string(3)}"
      end.join(Factory.non_word_chars.sample)
      assert_equal string.gsub(/[^\w]+/, "-"), subject.new(string, @args)
    end

    should "allow passing a custom preprocessor proc" do
      string = "#{Factory.string}-#{Factory.string.upcase}"
      exp = string.downcase
      assert_equal exp, subject.new(string, @args.merge(:preprocessor => :downcase.to_proc))

      preprocessor = proc{ |s| s.gsub(/[A-Z]/, "a") }
      exp = preprocessor.call(string)
      assert_equal exp, subject.new(string, @args.merge(:preprocessor => preprocessor))
    end

    should "allow passing a custom separator" do
      separator = Factory.non_word_chars.sample

      invalid_char = (Factory.non_word_chars - [separator]).sample
      string = "#{Factory.string}#{invalid_char}#{Factory.string}"
      exp = string.gsub(/[^\w]+/, separator)
      assert_equal exp, subject.new(string, @args.merge(:separator => separator))

      # it won"t change the separator in the strings
      string = "#{Factory.string}#{separator}#{Factory.string}"
      exp = string
      assert_equal string, subject.new(string, @args.merge(:separator => separator))

      # it will change the default separator now
      string = "#{Factory.string}-#{Factory.string}"
      exp = string.gsub("-", separator)
      assert_equal exp, subject.new(string, @args.merge(:separator => separator))
    end

    should "change underscores into its separator unless allowed" do
      string = "#{Factory.string}_#{Factory.string}"
      assert_equal string.gsub("_", "-"), subject.new(string, @args)

      exp = string.gsub("_", "-")
      assert_equal exp, subject.new(string, @args.merge(:allow_underscores => false))

      assert_equal string, subject.new(string, @args.merge(:allow_underscores => true))
    end

    should "not allow multiple separators in a row" do
      string = "#{Factory.string}--#{Factory.string}"
      assert_equal string.gsub(/-{2,}/, "-"), subject.new(string, @args)

      # remove separators that were added from changing invalid chars
      invalid_chars = (Factory.integer(3) + 1).times.map{ Factory.non_word_chars.sample }.join
      string = "#{Factory.string}#{invalid_chars}#{Factory.string}"
      assert_equal string.gsub(/[^\w]+/, "-"), subject.new(string, @args)
    end

    should "remove leading and trailing separators" do
      string = "-#{Factory.string}-#{Factory.string}-"
      assert_equal string[1..-2], subject.new(string, @args)

      # remove separators that were added from changing invalid chars
      invalid_char = Factory.non_word_chars.sample
      string = "#{invalid_char}#{Factory.string}-#{Factory.string}#{invalid_char}"
      assert_equal string[1..-2], subject.new(string, @args)
    end
  end
end
