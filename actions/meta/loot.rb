module Shiva
  class Loot < Action
    Skinnable = %w(
      cerebralite lich crawler
      sidewinder
      warg mastodon hinterboar
      brawler warlock fanatic
      dreadsteed titan giant
    )

    def priority
      Priority.get(:high) - 1
    end

    def dead
      GameObj.npcs.to_a
      .select {|foe| foe.status.include?("dead")}
      .reject {|foe| %w(glacei).include?(foe.noun)}
    end

    def should_unhide?
      return false if self.env.foes.any? {|f| %w(crawler siphon).include?(f.noun)} and hidden?
      return false if self.env.foes.any? {|f| f.name =~ /gigas|warg/} and hidden?
      return false if self.env.foes.any? {|f| f.name =~ /grizzled|ancient/} and hidden?
      return true unless hidden?
      return true if hidden? and self.env.foes.size < 5
      return false
    end

    def available?
      Claim.mine? and
      not self.env.name.eql?(:duskruin) and
      not self.dead.empty? and
      self.should_unhide? and
      Wounds.head < 2 and
      Wounds.nsys < 2 and
      Wounds.leftEye < 2 and
      Wounds.rightEye < 2 and
      (Group.leader? or Group.empty?)
    end

    def use_config_dagger
      Config.skinning_weapon && Containers.harness.where(name: Config.skinning_weapon).first
    end

    def use_skinning_dagger
      waitrt?
      if dagger = self.use_config_dagger
        prev_left_hand = Char.left
        begin
          3.times { waitrt?; Containers.harness.add(prev_left_hand); break if Char.left.nil? } unless prev_left_hand.nil?
          dagger.take
          yield(:left)
          Containers.harness.add(dagger)
          #prev_left_hand.take
          return :ok
        rescue => exception
          Log.out(exception)
          Containers.add(Char.left) unless Char.left.nil?
          3.times { waitrt?; prev_left_hand.take; break if Char.left.id.eql?(prev_left_hand.id)}
        end
      elsif self.dagger_hand
        yield Char.send(self.dagger_hand)
      end
    end

    def dagger_hand
      return :right if Tactic::Nouns::Dagger.include?(Char.right.noun)
      return :left if Tactic::Nouns::Dagger.include?(Char.left.noun)
      return nil
    end

    def maybe_skin(creature)
      return :unskinnable unless Skinnable.include?(creature.noun)
      return :no_skill unless (Skills.survival + Skills.firstaid) / (Char.level * 0.5) > 0.5
      self.use_skinning_dagger do |hand|
        fput "skin #%s %s" % [creature.id, hand]
      end
      return :ok
    end

    def apply()
      waitrt?
      return if self.dead.empty?
      left_hand = Char.left
      lootable = self.dead.first
      creature = Creature.new(lootable)
      self.maybe_skin(creature)
      creature.search()
      wait_while { GameObj[creature.id] }
      left_hand.take unless Char.left.id.eql?(left_hand) or left_hand.nil?
    end
  end
end