module Shiva
  class Wander < Action
    def priority
      15
    end

    def available?(foe)
      return false unless @env.name.eql?("Bandits")
      return false unless Group.leader? or Group.empty?
      return true if foe.nil?
      return true unless Claim.mine?
      return false unless Group.members.map(&:status).flatten.empty?
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