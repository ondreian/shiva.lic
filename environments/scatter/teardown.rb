module Shiva
  module Scatter
    class Teardown < Stage
      def turn_in_bounty!
        Task.advance("Icemule Trace")
      end

      def go2_sands
        return self.symbol_of_return if Society.status =~ /Voln/ && Society.rank.eql?(26)
        Go2.sands
      end

      def base
        18698 # Oberwood
      end

      def others?
        (GameObj.pcs.to_a.map(&:noun) - Cluster.connected).size > 0
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

      def symbol_of_return
        from_id = Room.current.id
        fput "symbol return"
        ttl = Time.now + 2
        wait_while {Room.current.id.eql?(from_id) and Time.now < ttl}
      end
      
      def box_routine()
        Log.out("others=%s box=%s" % [self.others?, self.box?], label: %i(teardown)) # if self.others? and self.box?
        Script.run("boxes", "drop")
        Script.run("spa", "--floor --loot") if Skills.pickinglocks > Char.level * 2 and Effects::Buffs.time_left("Major Loot Boost") < 3
      end

      def apply(env)
        waitcastrt?
        waitrt?
        self.go2_sands
        self.turn_in_bounty! if Group.empty?
        self.return_to_base
        ttl = Time.now + 10
        wait_until("waiting on return to base...") {
          Room.current.id.eql?(self.base) or (Time.now > ttl and not Script.running?("go2"))
        }
        fail "could not return to base" unless Room.current.id.eql?(self.base)
        Team.request_healing if Char.total_wound_severity > 0 or percenthealth < 100
        wait_while("waiting on healing") {Char.total_wound_severity > 0}
        Char.unarm
        wait_while("waiting on hands") {Char.left or Char.right} unless Char.left.type =~ /box/
        self.box_routine()
        self.sell_loot()
        Script.start("waggle")
        exit
      end
    end
  end
end