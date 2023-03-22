module Shiva
  class Whalelot < Action
    module Outcomes
      Ok  = %r[A surge of radiant energy coalesces around you and those nearby.]
      Err = %r[Your armor prevents the spell from working correctly.]
      All = Regexp.union(Ok, Err)
    end

    def priority
      Priority.get(:high)
    end

    def active?
      Effects::Spells.active?("Zealot")
    end

    def available?
      Vars["sk/known"].include?("1917") and
      checkmana > 70 and
      not self.active? and
      self.env.foes.empty?
    end

    def apply()
      case dothistimeout("incant 1917", 3, Outcomes::All)
      when Outcomes::Ok
        ttl = Time.now + 2
        wait_until {self.active? or Time.now > ttl}
      end
    end
  end
end