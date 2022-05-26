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

    def travel_to_hunting_area
      if Group.empty?
        Script.run("go2", "%s --disable-confirm" % self.env.entry.to_s)
      else
        Script.run("rally", "%s" % self.env.entry.to_s)
      end
    end

    def activate_group
      return unless Group.leader?
      return if Group.empty?
      Group.members.map(&:noun).map do |member|
        Cluster.cast(member, 
          channel: :script, 
          script:  :shiva,
          args:    %(--env=#{self.env.name}),
        )
      end
    end
    
    def apply()
      fput "flag obvious on" if Skills.stalkingandhiding > Char.level
      fput "exp"
      fput "bounty"
      Group.check
      Char.arm
      return if @env.rooms.include?(Room.current.id.to_s)
      self.get_bounty!
      fail "you are encumbered" unless percentencumbrance.eql?(0)
      fail "you are injured"    if Char.total_wound_severity > 0
      wait_while("wait/mana") { percentmana < 80 } unless %w(Rogue Warrior).include?(Char.prof)
      fail "entry not defined for #{self.env.name}" unless self.env.entry
      self.env.before_main if self.env.respond_to?(:before_main)
      self.travel_to_hunting_area
      self.activate_group
      fail "did not travel to #{Room[self.env.entry].title.first}" unless Room.current.id.eql?(self.env.entry)
    end
  end
end