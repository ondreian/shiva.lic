module Shiva
  class ZealotStaff < Action
    @tags = %i(setup)

    def priority
      Priority.get(:high)
    end

    def active?
      Effects::Spells.active?("Zealot")
    end

    def staff
      Containers.harness.where(name: %[shining glowbark quarterstaff]).first
    end

    def available?
      checkmana > 70 and
      not self.active? and
      not self.staff.nil? and
      self.env.foes.empty?
    end

    def apply()
      staff = self.staff
      Hand.right {
        staff.take 
        fput "raise #%s" % staff.id
        ttl = Time.now + 2
        wait_until {self.active? or Time.now > ttl}
        waitrt?
        Containers.harness.add(staff)
      }
    end
  end
end