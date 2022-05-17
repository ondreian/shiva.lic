module Shiva
  class Setup
    attr_reader :controller, :env

    def initialize(controller)
      @controller = controller
      @env        = controller.env
    end

    def get_bounty!
      return :not_allowed unless Group.empty?
      return :skip if %i(cull dangerous heirloom).include?(Bounty.type)
      Task.advance(self.env.town) if self.env.town
    end
    
    def apply()
      fput "flag obvious on" if Skills.stalkingandhiding > Char.level
      Group.check
      Char.arm
      return if @env.rooms.include?(Room.current.id.to_s)
      self.get_bounty!
      fail "you are encumbered" unless percentencumbrance.eql?(0)
      fail "you are injured"    if Char.total_wound_severity > 0
      wait_while("wait/mana") { percentmana < 80 } unless %w(Rogue Warrior).include?(Char.prof)
      return Log.out("entry not defined for #{self.env.name}", %i(setup travel skip)) unless self.env.entry
      Script.run("go2", self.env.entry.to_s)
      fail "did not travel to #{Room[self.env.entry].title.first}" unless Room.current.id.eql?(self.env.entry)
    end
  end
end