module Shiva
  class Setup
    attr_reader :env

    def initialize(env)
      @env = env
    end

    def get_bounty!
      return :not_allowed unless Group.empty?
      return :skip if %i(cull dangerous heirloom).include?(Bounty.type)
      Task.advance(self.env.town) if self.env.town
    end

    def travel_to_hunting_area
      waitcastrt?
      waitrt?
      if Group.empty?
        Script.run("go2", "%s --disable-confirm" % self.env.entry.to_s)
      else
        Rally.group(self.env.entry.to_s)
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
      Group.check
      Arms.use
      return if @env.rooms.include?(Room.current.id.to_s)
      self.get_bounty!
      if percentencumbrance > 0
        Teardown.new(@env).box_routine 
        Arms.use
      end
      fail "you are encumbered" unless percentencumbrance.eql?(0)
      Conditions::Injured.handle!
      if !%w(Rogue Warrior).include?(Char.prof) and percentmana < 80
        Base.go2
        Team.request_mana(maxmana - checkmana)
        wait_while("wait/mana") { percentmana < 80 }
      end
      fail "entry not defined for #{self.env.name}" unless self.env.entry
      Script.run("shiva_setup") if Script.exists?("shiva_setup")
      self.travel_to_hunting_area
      self.activate_group
      fail "did not travel to #{Room[self.env.entry].title.first}" unless Room.current.id.eql?(self.env.entry)
    end
  end
end