module Shiva
  class Tonis < Action
    def priority
      1
    end

    def available?
      Spell[1035].known? and
      Spell[1035].affordable? and
      not Spell[1035].active?
    end

    def apply()
      Walk.apply do
        fput "release" unless checkprep.eql?("None") or checkprep.eql?("Song of Tonis")
        wait_until {checkprep.eql?("None") or checkprep.eql?("Song of Tonis")}
        Spell[1035].cast
        waitcastrt?
        ttl = Time.now + 1
        wait_until {Time.now > ttl or Spell[1035].active?}
      end
    end
  end
end