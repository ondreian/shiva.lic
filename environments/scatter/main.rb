module Shiva
  module Scatter
    class Main < Stage
      Danger = %w(crawler siphon master destroyer cerebralite doll)

      def foes
        return [] unless Claim.mine?
        Foes.reject {|foe| foe.noun.eql?("doll")}.sort_by do |foe|
          if foe.name =~ /grizzled|ancient/ or foe.noun.eql?("master")
            0
          elsif checkbounty.include?(foe.noun) and not Group.empty?
            1
          else
            2 + Danger.index(foe.noun) - foe.status.size
          end
        end
      end

    
      def apply(env)
        env.reset_start_time!

        loop {
          wait_until {Claim.mine? or checkpcs.nil?}
          action = Common::Act.call(env, self.foe)
          Log.out(action, label: %i(previous action))
          break if action.eql?(:rest)
        }
      end
    end
  end
end