require "much-slug"

module MuchSlug
  class HasSlugRegistry < ::Hash
    def initialize
      super{ |h, k| h[k] = Entry.new }
    end

    def register(
          attribute:,
          source:,
          preprocessor:,
          separator:,
          allow_underscores:)
      (attribute || MuchSlug.default_attribute).to_s.tap do |a|
        if allow_underscores.nil?
          allow_underscores = MuchSlug.default_allow_underscores
        end

        entry = self[a]
        entry.source_proc       = source.to_proc
        entry.preprocessor_proc = (preprocessor || MuchSlug.default_preprocessor).to_proc
        entry.separator         = separator || MuchSlug.default_separator
        entry.allow_underscores = !!allow_underscores
      end
    end

    class Entry
      attr_accessor :source_proc, :preprocessor_proc, :separator, :allow_underscores
    end
  end
end
