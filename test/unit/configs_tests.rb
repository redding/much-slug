require "assert"
require "much-slug/configs"

module MuchSlug::Configs

  class UnitTests < Assert::Context
    desc "MuchSlug::Configs"
    setup do
      @module = MuchSlug::Configs
    end
    subject{ @module }

    should have_imeths :new

    should "build a new configs hash" do
      configs = subject.new

      assert_kind_of ::Hash, configs
      assert_equal ::Hash.new, configs[Factory.string]
    end

  end

end
