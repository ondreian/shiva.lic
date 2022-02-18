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
      fput "release" unless checkprep.eql?("None") or checkprep.eql?("Song of Tonis")
      wait_until {checkprep.eql?("None") or checkprep.eql?("Song of Tonis")}
      fput "incant 1035"
    end
  end
end