require_relative "../../stage"

module Shiva
  module Sanctum
    class Setup < Stage
      def scripts
        %w(reaction lte effect-watcher)
      end

      def apply(env)
        Group.check
        Char.arm
      end
    end
  end
end