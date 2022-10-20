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

    DefaultBases = [
      18698, # Oberwood
      29881, # Hinterwilds
      29623, # Kraken's Fall
    ]

    def bases()
      return DefaultBases unless Vars["shiva/bases"]
      Vars["shiva/bases"].split(",").map(&:to_i)
    end

    def base
      Room.current.find_nearest(self.bases)
    end

    def others?
      (GameObj.pcs.to_a.map(&:noun) - Cluster.connected - %w(Greys)).size > 0
    end

    def box?
      GameObj.loot.any? {|i| i.type =~ /box/}
    end

    def return_to_base
      if Group.empty?
        Char.unhide if hidden?
        Script.run("go2", self.base.to_s)
      else
        $cluster_cli.stop("shiva") if Group.leader? and not Group.empty?
        Script.run("rally", self.base.to_s)
        fput "disband"
      end
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

    def loop_bounty(town)
      return if Boost.loot?
      loop {
        wait_while("mind/saturated") { Mind.saturated? }
        self.turn_in_bounty(town)
        self.return_to_base
        break unless Bounty.type.eql?(:succeeded)
      }
    end

    def report()
      _respond "<b>resting because of %s</b>" % $shiva_rest_reason
    end

    def cleanup(town)
      self.turn_in_bounty(town) if %i(report_to_guard skin heirloom_found).include? Bounty.type
      self.return_to_base
      ttl = Time.now + 10
      wait_until("waiting on return to base...") {
        Room.current.id.eql?(self.base) or (Time.now > ttl and not Script.running?("go2"))
      }
      fail "could not return to base" unless Room.current.id.eql?(self.base)
      Team.request_healing if Char.total_wound_severity > 0 or percenthealth < 100
      wait_while("waiting on healing") {Char.total_wound_severity > 1}
      Char.unarm
      wait_while("waiting on hands") {Char.left or Char.right} unless Char.left.type =~ /box/
      self.box_routine()
      
      if Bounty.type.eql?(:gem) and Task.sellables.size > 0
        self.turn_in_bounty(town)
        self.return_to_base
      end

      self.loop_bounty(town)
      #self.sell_loot()
      fput "boost exp" if Mind.saturated? and not Effects::Buffs.active?("Doubled Experience Boost") and Boost.loot?
      Script.run("waggle")
      self.report
      exit if $shiva_graceful_exit.eql?(true) or not Group.empty? or not Opts["daemon"]
      wait_while("waiting on mind") {percentmind > 80} unless Boost.loot?
    end

    def apply()
      self.env.before_teardown if self.env.respond_to?(:before_teardown)
      self.cleanup(self.env.town) if self.env.town
    end
  end
end