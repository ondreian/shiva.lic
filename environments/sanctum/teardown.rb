module Shiva
  module Sanctum
    class Teardown < Stage
      def apply(env)
        waitcastrt?
        waitrt?
        Common::Teardown.cleanup("Solhaven")
      end
    end
  end
end