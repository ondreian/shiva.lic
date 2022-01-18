module Shiva
  class LootArea < Action
    Dangerous = /doomstone|oblivion|urglaes/

    attr_reader :seen
    def initialize(*args)
      super(*args)
      @seen = []
    end

    def priority
      3
    end

    def nonce(items)
      @seen.concat items.map(&:id)
      @seen.uniq!
      return items
    end

    def loot
      GameObj.loot.to_a
        .reject {|item| 
          Trash.include?(item) or 
          item.id.start_with?("-") or 
          item.type.include?("junk") or
          item.noun.eql?("disk") or
          item.noun.eql?("bandana") or
          item.type.include?("food") or
          item.type.nil?
        }
        .reject {|item| @seen.include?(item.id)}
    end

    def available?
      Claim.mine? and
      self.loot.size > 0 and
      (Group.leader? or Group.empty?) and
      @env.foes.empty?
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
        @env.state = :rest
      when Ok
        :ok
      end
    end

    def slow_loot
      Containers.lootsack.add(*GameObj.loot.reject {|i|
        i.name =~ Dangerous or
        Trash.include?(i) or
        i.type =~ /junk|food|herb/
      })
    end



    def apply()
      Log.out(self.loot.map(&:name), label: %i(loot))
      self.nonce self.loot
      empty_left_hand
      if dangerous?
        self.slow_loot
      else
        self.fast_loot
      end
      empty_left_hand unless Char.left.nil?
      fill_left_hand
    end
  end
end