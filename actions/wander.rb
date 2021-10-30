module Shiva
  class Wander < Action
    def priority
      15
    end

    def allowed
      [Shiva::Bandits]
    end

    def available?(foe)
      return false unless Group.leader? or Group.empty?
      return false if (Group.members.map(&:noun) - checkpcs.to_a).size > 0
      return false if Group.members.map(&:status).flatten.compact.size > 0
      return true unless Claim.mine?
      return true if foe.nil?
      return false
    end

    def apply()
      case @env.name.downcase.to_sym
      when :bandits
        Log.out("wander -> bandits", label: %i(action))
        Stance.forward
        Bandits.crawl(@env.area)
      else
        fail "wander not implemented for {env=#{@env.name}} yet!"
      end
    end
  end
end