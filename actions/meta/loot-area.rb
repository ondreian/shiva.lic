module Shiva
  # You note some treasure of interest and manage to pick up an engraved thanot chest but quickly realize you have no space in which to stow it.
  class LootArea < Action
    
    attr_reader :seen
    def initialize(*args)
      super(*args)
      @seen = []
    end

    def priority
      Priority.get(:high) - 1
    end

    def unseen()
      self.loot.reject { |item| @seen.include?(item.id)}
    end

    def nonce(items)
      items.reject! {|item| @seen.include?(item.id)}
      @seen.concat items.map(&:id)
      @seen.uniq!
      return items
    end

    def loot
      GameObj.loot.to_a.reject {|item| Trash.include?(item) }
    end

    def heirloom?
      Bounty.task.heirloom and GameObj.loot.any? {|i| i.name.end_with?(Bounty.task.heirloom)}
    end

    def safe?
      return false if Room.current.location.include?("Hinterwilds") and not self.env.foes.empty?
      return true if self.heirloom?
      return true if self.env.foes.size < 2
      self.env.foes.empty?
    end

    def available?
      Lich::Claim.mine? and
      (self.unseen.size > 0 or self.dead.size > 0)and
      (Group.leader? or Group.empty?) and
      self.safe?
    end

    def dead
      GameObj.npcs.to_a
        .select {|foe| foe.status.include?("dead")}
        .reject {|foe| %w(glacei).include?(foe.noun)}
    end

    def apply()
      return unless Lich::Claim.mine?
      this_loot = self.nonce self.loot
      return if this_loot.empty? and self.dead.empty?
      Script.run("eloot")
    end
  end
end