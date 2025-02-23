module Shiva
  class Teardown
    attr_reader :env

    def initialize(env)
      @env = env
    end

    def turn_in_bounty(town)
      return :not_allowed unless Group.empty?
      return :skip if %i(cull dangerous heirloom).include?(Bounty.type)
      return :skip if %i(gem skin).include?(Bounty.type) and Task.sellables.empty?
      Task.advance(town)
    end

    def others?
      (GameObj.pcs.to_a.map(&:noun) - Cluster.connected).size > 0
    end

    def box?
      GameObj.loot.any? {|i| i.type =~ /box/}
    end

    def box_routine(town = nil)
      Char.unarm
      Log.out("running box routine...")
      return Boxes.drop if Boxes.picker?
      Task.room(town, "advguild").id.go2 unless town.nil?
      Script.run("shiva_teardown") if Script.exists?("shiva_teardown")
      Base.go2
    end

    def report()
      _respond "<b>resting because of %s</b>" % $shiva_rest_reason
    end

    def cleanup(town)
      Rally.group(Base.closest) if Group.leader? and not Group.empty?
      self.turn_in_bounty(town) if %i(report_to_guard skin heirloom_found).include? Bounty.type
      Base.go2
      Conditions::Injured.handle!
      wait_while("cleanup:waiting on healing") {Char.total_wound_severity > 1}
      Char.unarm
      
      wait_while("waiting on hands") {Char.left or Char.right} unless Char.left.type =~ /box/
      
      self.box_routine(town)
      
      if Bounty.type.eql?(:gem) and Task.sellables.size > 0
        self.turn_in_bounty(town)
        Base.go2
      end
      
      self.report
    end

    def apply()
      self.cleanup(self.env.town) if self.env.town
    end
  end
end