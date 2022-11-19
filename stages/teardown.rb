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
      (GameObj.pcs.to_a.map(&:noun) - Cluster.connected - %w(Greys)).size > 0
    end

    def box?
      GameObj.loot.any? {|i| i.type =~ /box/}
    end

    def sell_loot()
      Script.run("give", "all uncut (diamond|emerald) Szan") if checkpcs.include?("Szan")
      if Char.name.eql?("Szan")
        Script.run("prune-gems")
        Script.run("sell", "--deposit --skins")
      else
        Script.run("sell", "--deposit --gems --skins")
      end
    end

    def message(receiver, box_count)
      return unless defined? LNet
      LNet.send_message(attr={'type'=>'private', 'to'=> receiver}, "There are now %s boxes on the ground at Oberwood" % box_count)
    end

    def box_routine()
      Char.unarm
      Log.out("running box routine...")
      #return unless Room.current.id.eql? 18698
      return Boxes.drop if Boxes.picker?
      Script.run("eloot", "sell")
    end

    def report()
      _respond "<b>resting because of %s</b>" % $shiva_rest_reason
    end

    def cleanup(town)
      cleanup_start = Time.now
      self.turn_in_bounty(town) if %i(report_to_guard skin heirloom_found).include? Bounty.type
      Base.go2
      fail "could not return to base" unless Room.current.id.eql?(Base.closest)
      Team.request_healing if Char.total_wound_severity > 0 or percenthealth < 100
      wait_while("waiting on healing") {Char.total_wound_severity > 1}
      Char.unarm
      wait_while("waiting on hands") {Char.left or Char.right} unless Char.left.type =~ /box/
      self.box_routine()
      
      if Bounty.type.eql?(:gem) and Task.sellables.size > 0
        self.turn_in_bounty(town)
        Base.go2
      end

      fput "boost exp" if Mind.saturated? and not Effects::Buffs.active?("Doubled Experience Boost") and not Boost.loot?
      
      self.report
      exit if $shiva_graceful_exit.eql?(true) or not Group.empty? or not Opts["daemon"]
      wait_until("waiting for burrow to reset") {Time.now > cleanup_start + 60} if $shiva_rest_reason.eql?(:burrowed)
      wait_while("waiting on mind") {Mind.saturated?} unless Boost.loot?
    end

    def apply()
      self.env.before_teardown if self.env.respond_to?(:before_teardown)
      self.cleanup(self.env.town) if self.env.town
    end
  end
end