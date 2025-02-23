module Shiva
  class Haste < Action
    @tags = %i(setup)
    def priority
      Priority.get(:high) - 1
    end

    def low_duration?
      Effects::Buffs.time_left("Celerity") * 60 < 5
    end

    def available?
      Spell[506].known? and
      Spell[506].affordable? and
      self.low_duration?
    end

    def apply()
      fput "release" unless checkprep.eql?("None") or checkprep.eql?("Haste")
      wait_until {checkprep.eql?("None") or checkprep.eql?("Haste")}
      #Spell[506].cast
      fput "incant 506"
      #waitcastrt?
      ttl = Time.now + 1
      wait_while {Time.now < ttl and self.low_duration?}
    end
  end
end