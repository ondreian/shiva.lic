module Shiva
  class Rest < Action
    Minute = 60
    
    def initialize(*args)
      super(*args)
    end

    def casting_impaired?
      Wounds.head > 1 or
      Wounds.nsys > 1 or
      Wounds.rightHand > 1
    end

    def priority
      return -100 if self.casting_impaired? 
      return -1
    end

    def out_of_mana?
      return false if %w(Warrior Rogue Monk).include?(Char.prof)
      return true  if percentmana < 20 and Char.prof.eql?("Bard")
      return true  if percentmana < 10
      return false
    end

    def wounded?
      return true if Wounds.head > 1
      return false if Team.has_healer?
      return false if Char.prof.eql?("Empath")
      return false unless Group.empty?
      Injuries.wounds.any? {|w| w > 1}
    end

    def bleeding?
      return false if Team.has_healer?
      return false if Char.prof.eql?("Empath")
      return false unless Group.empty?
      percenthealth < 70
    end

    def reason
      return false if XMLData.room_id.eql? 113001
      return false if %i(escort bandits invasion).include?(self.env.name)
      return :graceful_exit if $shiva_graceful_exit.eql?(true)
      return :burrowed if Effects::Debuffs.active?("Burrowed")
      return :overexerted if Effects::Debuffs.active?("Overexerted") and not Char.prof.eql?("Empath")
      #return :interrupt if self.env.state.eql?(:rest)
      return :full_containers if Char.left.type =~ /box/ and not Script.running?("give")
      return :encumbrance if percentencumbrance > 10
      return :wounded if self.wounded?
      return :health if self.bleeding?
      return :mana if self.out_of_mana?
      # environ effects
      return :hypothermia if Conditions::Hypothermia.status > 40
      return :dread if Conditions::Dread.crushing > 1
      return :bandits_done if self.env.name.eql?(:bandits) and Bounty.type.eql?(:report_to_guard)

      return false if Boost.loot?

      return :bounty_turn_in if Task.can_complete? && (percentmind.eql?(100) && !Mind.saturated?) && Group.empty? && !Boost.loot?
      return :uptime if @env.uptime > (20 * Minute) && percentmind.eql?(100)
      return :get_bounty if Bounty.type.eql?(:none) and not Task.cooldown? and not Boost.loot?
      return :unknown if @env.state.eql?(:rest)
      return false
    end

    def available?(foe)
      return false unless Group.leader?
      return false unless self.env.boundaries
      @reason = self.reason
      $shiva_rest_reason = @reason if @reason.is_a?(Symbol)
      @reason.is_a?(Symbol)
    end

    def apply()
      Log.out(@reason, label: %i(rest reason))
      return unless Claim.mine?
      sleep 1 unless @reason.eql?(:wounded)
      loot_area = self.env.action(:lootarea)
      search_dead_creatures = self.env.action(:loot)
      Log.out("{search_dead=%s, loot_area=%s}" % [search_dead_creatures.available?, loot_area.available?])
      if search_dead_creatures.available?
        search_dead_creatures.apply
        sleep 1
      end
      loot_area.apply
    end
  end
end