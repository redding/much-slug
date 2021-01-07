# frozen_string_literal: true

require "assert/factory"

module Factory
  extend Assert::Factory

  def self.non_word_chars
    ( (" ".."/").to_a +
      (":".."@").to_a +
      ("[".."`").to_a +
      ("{".."~").to_a -
      ["-", "_"]
    ).freeze
  end
end
