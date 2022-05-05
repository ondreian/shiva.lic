module Shiva
  class Rest < Action
    Minute = 60

    Injuries = Wounds.singleton_methods
      .map(&:to_s)
      .select do |m| m.downcase == m && m !~ /_/ end.map(&:to_sym)
    
    def initialize(*args)
      super(*args)
      @start_time = Time.now
    end

    def uptime()
      Time.now - @start_time
    end

    def priority
      1
    end

    def allowed
      [Shiva::Scatter, Shiva::Sanctum]
    end

    def wounds
      Injuries.map {|m| Wounds.send(m)}
    end

    def out_of_mana?
      return false if %w(Warrior Rogue Monk).include?(Char.prof)
      return true  if percentmana < 20 and Char.prof.eql?("Bard")
      return true  if percentmana < 10
      return false
    end

    def wounded?
      return self.wounds.any? {|w| w > 1} if Group.empty?
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
      return :over_exerted if Effects::Debuffs.active?("Overexerted")
      return :full_containers if Char.left.type =~ /box/ and not Script.running?("give")
      return :state if @env.state.eql?(:rest)
      return :encumbrance if percentencumbrance > 10
      return :wounded if self.wounded?
      return :health if self.bleeding?
      return :bounty if Bounty.task.type.eql?(:report_to_guard) && percentmind.eql?(100)
      return :uptime if self.uptime > (20 * Minute) && percentmind.eql?(100)
      return :mana if self.out_of_mana?
      return false
    end

    def available?(foe)
      return false unless Group.leader?
      @reason = self.reason
      @reason.is_a?(Symbol)
    end

    def apply()
      Log.out(@reason, label: %i(rest reason))
      loot = @env.action("LootArea")
      loot.apply if Claim.mine?
    end
  end
end