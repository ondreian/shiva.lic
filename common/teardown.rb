module Shiva
  module Common
    module Teardown
      def self.turn_in_bounty(town)
        return :not_allowed unless Group.empty?
        return :skip if %i(cull dangerous heirloom).include?(Bounty.type)
        return :skip if %i(gem skin).include?(Bounty.type) and Task.sellables.empty?
        Task.advance(town)
      end

      Bases = [
        18698, # Oberwood
        29881, # Hinterwilds
      ]
      def self.base
        Room.current.find_nearest(Bases)
      end

      def self.others?
        (GameObj.pcs.to_a.map(&:noun) - Cluster.connected - %w(Greys)).size > 0
      end

      def self.box?
        GameObj.loot.any? {|i| i.type =~ /box/}
      end

      def self.return_to_base
        if Group.empty?
          Char.unhide if hidden?
          Script.run("go2", self.base.to_s)
        else
          $cluster_cli.stop("shiva") if Group.leader? and not Group.empty?
          Script.run("rally", self.base.to_s)
          fput "disband"
        end
      end

      def self.sell_loot()
        Script.run("give", "all uncut (diamond|emerald) Szan") if checkpcs.include?("Szan")
        if Char.name.eql?("Szan")
          Script.run("prune-gems")
          Script.run("sell", "--deposit --skins")
        else
          Script.run("sell", "--deposit --gems --skins")
        end
      end

      def self.message(receiver, box_count)
        return unless defined? LNet
        LNet.send_message(attr={'type'=>'private', 'to'=> receiver}, "There are now %s boxes on the ground at Oberwood" % box_count)
      end
      
      def self.box_routine()
        Log.out("others=%s box=%s" % [self.others?, self.box?], label: %i(teardown)) # if self.others? and self.box?
        Containers.lootsack.where(type: /box/).each { |box|
          box.take
          fput "drop #%s" % box.id
          wait_until("waiting on box drop") {GameObj.loot.map(&:id).include?(box.id)}
        }
        return if Skills.pickinglocks < Char.level * 2 # no lockpicking skill
        box_count = GameObj.loot.to_a.select {|i| i.type.include?("box")}.size
        return if box_count.eql?(0)
        return self.message("Greys", box_count) if Mind.saturated? or Effects::Buffs.time_left("Major Loot Boost") > 3
        Script.run("spa", "--floor --loot")
      end

      def self.loop_bounty(town)
        return unless Effects::Buffs.time_left("Major Loot Boost") < 3
        loop {
          wait_while("mind/saturated") { Mind.saturated? }
          self.turn_in_bounty(town)
          self.return_to_base
          break unless Bounty.type.eql?(:succeeded)
        }
      end

      def self.cleanup(town)
        self.turn_in_bounty(town) if %i(report_to_guard skin heirloom_found).include? Bounty.type
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
        Script.run("boxes", "loot") unless self.others?
        
        if Bounty.type.eql?(:gem)
          self.turn_in_bounty(town)
          self.return_to_base
        end

        self.loop_bounty(town)
        self.sell_loot()
        fput "boost exp" if Mind.saturated? and not Effects::Buffs.active?("Doubled Experience Boost") and Effects::Buffs.time_left("Major Loot Boost") < 3
        Script.run("waggle")
        exit if $shiva_graceful_exit.eql?(true) or not Group.empty?
        wait_while("waiting on mind") {percentmind > 80} unless Effects::Buffs.time_left("Major Loot Boost") > 3
      end
    end
  end
end