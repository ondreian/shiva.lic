module Shiva
  class Loot < Action
    Skinnable = %w(
      cerebralite lich crawler
      sidewinder
      warg mastodon hinterboar
      brawler warlock fanatic
      dreadsteed
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
      (Group.leader? or
      Group.empty?)
    end

    def dagger_hand
      return :right if Tactic::Nouns::Dagger.include?(Char.right.noun)
      return :left if Tactic::Nouns::Dagger.include?(Char.left.noun)
      return nil
    end

    def maybe_skin(creature)
      return :unskinnable unless Skinnable.include?(creature.noun)
      return :no_skill unless (Skills.survival + Skills.firstaid) / (Char.level * 0.5) > 0.5
      return fput "skin #%s %s" % [creature.id, self.dagger_hand] if self.dagger_hand
      dagger = Containers.harness.where(noun: Tactic::Nouns::Dagger).first
      return :no_dagger if dagger.nil?
      right = Char.right
      Containers.harness.add(right) unless Char.left.nil? or Char.right.nil?
      dagger.take
      fput "skin #%s %s" % [creature.id, self.dagger_hand]
      Containers.harness.add(dagger)
      Containers.harness.where(id: right.id).first.take()
      return :ok
    end

    def apply()
      waitrt?
      self.dead.each {|foe|
        creature = Creature.new(foe)
        self.maybe_skin(creature)
        creature.search()
      }
    end
  end
end