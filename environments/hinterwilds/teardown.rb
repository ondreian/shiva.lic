module Shiva
  module Hinterwilds
    class Teardown < Stage
      def apply(env)
        waitcastrt?
        waitrt?
        Script.run("ring", "4")
        # Common::Teardown.cleanup("Hinterwilds")
        exit
      end
    end
  end
end