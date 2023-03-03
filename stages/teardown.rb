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

    def box_routine(town = nil)
      Char.unarm
      Log.out("running box routine...")
      #return unless Room.current.id.eql? 18698
      return Boxes.drop if Boxes.picker?
      Task.room(town, "advguild").id.go2 unless town.nil?
      # try to deposit boxes only, unless till encumbered, and then go take advantage of loot boost
      if Boost.loot?
        Script.run("eloot", "pool deposit")
        return Script.run("eloot", "sell") if percentencumbrance > 0
      end
      
      Script.run("eloot", "sell")
    end

    def report()
      _respond "<b>resting because of %s</b>" % $shiva_rest_reason
    end

    def cleanup(town)
      self.turn_in_bounty(town) if %i(report_to_guard skin heirloom_found).include? Bounty.type
      Conditions::Injured.handle!
      wait_while("waiting on healing") {Char.total_wound_severity > 1}
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