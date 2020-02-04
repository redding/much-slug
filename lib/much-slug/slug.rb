module MuchSlug
  module Slug
    def self.new(string, preprocessor:, separator:, allow_underscores: true)
      regexp_escaped_sep = Regexp.escape(separator)

      slug = preprocessor.call(string.to_s.dup)
      # Turn unwanted chars into the separator
      slug.gsub!(/[^\w#{regexp_escaped_sep}]+/, separator)
      # Turn underscores into the separator, unless allowing
      slug.gsub!(/_/, separator) unless allow_underscores
      # No more than one of the separator in a row.
      slug.gsub!(/#{regexp_escaped_sep}{2,}/, separator)
      # Remove leading/trailing separator.
      slug.gsub!(/\A#{regexp_escaped_sep}|#{regexp_escaped_sep}\z/, "")
      slug
    end
  end
end
