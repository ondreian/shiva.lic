module Shiva
  class Skin < Action
    Skinnable = %w(
      cerebralite lich crawler
      sidewinder
      warg mastodon hinterboar
      brawler warlock fanatic
      dreadsteed titan giant
      bear lion
    )

    Skinned ||=[]

    def priority
      Priority.get(:high) - 3
    end

    def skinnable
      GameObj.npcs.to_a
      .select {|foe| foe.status.include?("dead")}
      .select {|foe| Skinnable.include?(foe.noun)}
      .reject {|foe| foe.name =~ /deathsworn/}
      .reject {|foe| Skinned.include?(foe.id)}
    end

    def should_unhide?
      return false if self.env.foes.any? {|f| %w(crawler siphon).include?(f.noun)} and hidden?
      return false if self.env.foes.any? {|f| f.name =~ /gigas|warg/} and hidden?
      return false if self.env.foes.any? {|f| f.name =~ /grizzled|ancient/} and hidden?
      return true unless hidden?
      return true if hidden? and self.env.foes.size < 5
      return false
    end

    def skilled?
      (Skills.survival + Skills.firstaid) / (Char.level * 0.5) > 0.5
    end

    def available?
      Lich::Claim.mine? and
      # not Tactic.uac? and
      self.skilled? and
      not self.env.name.eql?(:duskruin) and
      not self.skinnable.empty? and
      self.should_unhide? and
      Wounds.head < 2 and
      Wounds.nsys < 2 and
      Wounds.leftEye < 2 and
      Wounds.rightEye < 2 and
      (Group.leader? or Group.empty?)

    end

    def use_config_dagger
      if Config.skinning_weapon
        Containers.harness.where(name: Config.skinning_weapon).first
      else
        Containers.harness.find {|item| Tactic::Nouns::Dagger.include?(item.noun) }
      end
    end

    def use_skinning_dagger
      waitrt?
      if dagger = self.use_config_dagger
        prev_left_hand = Char.left
        tries = 0
        begin
          3.times { waitrt?; Containers.harness.add(prev_left_hand); break if Char.left.nil? } unless prev_left_hand.nil?
          dagger.take
          #fput "glance"
          yield(self.dagger_hand)
          Containers.harness.add(dagger)
          #prev_left_hand.take
          return :ok
        rescue => exception
          tries = tries + 1
          Log.out(exception)
          if tries < 4
            retry
          else
            raise exception
          end
        end
      elsif self.dagger_hand
        yield(self.dagger_hand)
      end
    end

    def dagger_hand
      return :right if Tactic::Nouns::Dagger.include?(Char.right.noun)
      return :left if Tactic::Nouns::Dagger.include?(Char.left.noun)
      return nil
    end

    def apply()
      waitrt?
      left_hand = Char.left
      self.use_skinning_dagger do |hand|
        self.skinnable.each do |creature|
          #Log.out("hand=%s" % hand)
          fput "skin #%s %s" % [creature.id, hand]
          Skinned << creature.id
        end
      end
      left_hand.take unless Char.left.id.eql?(left_hand) or left_hand.nil?
    end
  end
end