module Shiva
  class Dread < Action
    def priority
      Priority.get(:high)
    end

    def available?(foe)
      Shiva::Conditions::Dread.creeping > 8 and (Group.empty? or Group.leader?)
    end
    
    def pre_move_hook()
      return unless Lich::Claim.mine?
      search = @env.action(:loot)
      loot = @env.action(:lootarea)
      loot.apply
    end

    def apply()
      Stance.defensive
      self.pre_move_hook
      #from = Room.current.id
      fput "unhide" if hidden?
      Script.run("go2", "32469")
      wait_while {Shiva::Conditions::Dread.creeping > 0}
      nearest = Room.current.find_nearest self.env.rooms
      Spell[506].cast if Spell[506].known? and Spell[506].affordable?
      Script.run("go2", "%s" % nearest)
    end
  end
end