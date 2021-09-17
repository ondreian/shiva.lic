module Shiva
  class LootArea < Action
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
      @env.foes.empty? and
      (Group.leader? or Group.empty?)
    end

    def apply()
      Log.out(self.loot.map(&:name), label: %i(loot))
      self.nonce self.loot
      empty_left_hand
      fput "loot area"
      empty_left_hand unless Char.left.nil?
      fill_left_hand
    end
  end
end