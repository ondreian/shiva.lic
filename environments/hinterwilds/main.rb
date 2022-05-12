module Shiva
  module Hinterwilds
    class Main < Stage
      Danger = %w(
        warg hinterboar wendigo bloodspeaker cannibal
        golem berserker skald shield-maiden mastodon
      )

      def foes
        return [] unless Claim.mine?
        Foes.sort_by do |foe|
          if foe.name =~ /grizzled|ancient/
            0
          elsif checkbounty.include?(foe.noun) and not Group.empty?
            1
          else
            2 + Danger.index(foe.noun) - foe.status.size
          end
        end
      end

      def apply(env)
        loop {
          wait_until {Claim.mine? or checkpcs.nil?}
          action = Common::Act.call(self.env, self.foe)
          Log.out(action, label: %i(previous action))
          break if action.eql?(:rest)
        }
      end
    end
  end
end