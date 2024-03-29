module Shiva
  # You note some treasure of interest and manage to pick up an engraved thanot chest but quickly realize you have no space in which to stow it.
  class LootArea < Action
    Dangerous = /doomstone|urglaes/

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
      return true if self.heirloom?
      self.env.foes.empty?
    end

    def available?
      Claim.mine? and
      self.unseen.size > 0 and
      (Group.leader? or Group.empty?) and
      self.safe?
    end

    def dangerous?
      GameObj.loot.any? {|i| i.name =~ Dangerous }
    end

    Err = Regexp.union(
      %r{You note some treasure of interest but are unable to pick any up.},
      %r{quickly realize you have no space in which to stow it.},
      %r{you find yourself unable to hold any more items},
    )
    Ok  = Regexp.union(
      %r{With a discerning eye, you gather up what treasure you find worthwhile and casually stow it away.},
      %r{There is no loot.}
    )

    def fast_loot
      case dothistimeout "loot area", 3, Regexp.union(Ok, Err)
      when Err
        self.env.state = :rest
        :full
      when Ok
        :ok
      end
    end

    def slow_loot(area_loot)
      Containers.lootsack.add(*area_loot)
    end

    def loot_silvers
      fput "get coins"
      waitrt?
    end

    def apply()
      this_loot = self.nonce self.loot
      return if this_loot.empty?
      Log.out(self.loot.map(&:name), label: %i(loot))
      waitrt?
      self.loot_silvers if GameObj.loot.any? {|i| i.name.eql?(%[some silver coins])}
      this_loot.reject! {|i| i.name.eql?(%[some silver coins])}
      return if this_loot.empty?
      Hand.use {
        if self.dangerous?
          self.slow_loot(this_loot)
          empty_left_hand unless Tactic.ranged?
        else
          result = self.fast_loot
          return if result.eql?(:full)
          self.slow_loot(self.loot) if self.loot && !self.env.state.eql?(:rest)
          empty_left_hand unless Tactic.ranged?
        end
        
      }
    end
  end
end