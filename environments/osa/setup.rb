require_relative "../../stage"

module Shiva
  module Osa
    class Setup < Stage
      def scripts
        %w(reaction effect-watcher lte)
      end

      def apply(env)
        @env.area.claim!
        Char.arm
        Group.check
      end
    end
  end
end