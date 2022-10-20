module Shiva
  class Rest < Action
    Minute = 60
    
    def initialize(*args)
      super(*args)
    end

    def priority
      -1
    end

    def out_of_mana?
      return false if %w(Warrior Rogue Monk).include?(Char.prof)
      return true  if percentmana < 20 and Char.prof.eql?("Bard")
      return true  if percentmana < 10
      return false
    end

    def wounded?
      return Injuries.wounds.any? {|w| w > 1} if Group.empty?
      return false if Char.prof.eql?("Empath")
      Team.has_healer?
    end

    def bleeding?
      return percenthealth < 70 if Group.empty?
      return false if Char.prof.eql?("Empath")
      Team.has_healer?
    end

    def reason
      return :graceful_exit if $shiva_graceful_exit.eql?(true)
      return :burrowed if Effects::Debuffs.active?("Burrowed")
      return :over_exerted if Effects::Debuffs.active?("Overexerted") and not Char.prof.eql?("Empath")
      return :interrupt if self.env.state.eql?(:rest)
      return :full_containers if Char.left.type =~ /box/ and not Script.running?("give")
      return :encumbrance if percentencumbrance > 10
      return :wounded if self.wounded?
      return :health if self.bleeding?
      return :bounty if Task.can_complete? && percentmind.eql?(100) && Group.empty? && !Boost.loot?
      return :uptime if @env.uptime > (20 * Minute) && percentmind.eql?(100)
      return :mana if self.out_of_mana?
      return :unknown if @env.state.eql?(:rest)
      return :hypothermia if Hypothermia.status > 60
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
      search_dead_creatures = @env.action(:loot)
      search_dead_creatures.apply if search_dead_creatures.available?
      sleep 1 unless @reason.eql?(:wounded)
      loot_area = @env.action(:lootarea)
      loot_area.apply 
    end
  end
end