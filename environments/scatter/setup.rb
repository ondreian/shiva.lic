require_relative "../../stage"

module Shiva
  module Scatter
    class Setup < Stage
      Entry = 12240 # [The Rift, Scatter]

      def scripts
        %w(reaction lte effect-watcher)
      end

      def get_bounty!
        Task.advance("Icemule Trace")
      end

      def apply(env)
        fput "flag obvious on"
        #Script.run("ring", "--link")
        Group.check
        Char.arm
        return if XMLData.room_title.include?("[The Rift, Scatter]")
        self.get_bounty!
        #fail "debug mode"
        fail "you are encumbered" unless percentencumbrance.eql?(0)
        Script.run("go2", Entry.to_s)
        fail "did not travel to scatter" unless Room.current.id.eql?(Entry)
      end
    end
  end
end