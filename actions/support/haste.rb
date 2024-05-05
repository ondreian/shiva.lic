module Shiva
  class Haste < Action
    def priority
      Priority.get(:high) - 1
    end

    def available?
      Spell[506].known? and
      Spell[506].affordable? and
      not Spell[506].active?
    end

    def apply()
      fput "release" unless checkprep.eql?("None") or checkprep.eql?("Haste")
      wait_until {checkprep.eql?("None") or checkprep.eql?("Haste")}
      Spell[506].cast
      #waitcastrt?
      #ttl = Time.now + 1
      #wait_until {Time.now > ttl or Spell[506].active?}
    end
  end
end