module Shiva
  class Unstun < Action
    def priority
      4
    end

    def stunned_member
      Group.members.find {|mem| mem.status.include?("stunned")}
    end

    def available?
      Spell[108].known? and
      Spell[108].affordable? and
      self.stunned_member
    end

    def apply()
      fput "release" unless checkprep.eql?("None")
      Spell[108].cast self.stunned_member
    end
  end
end