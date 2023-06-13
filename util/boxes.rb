module Shiva
  module Boxes
    Dropped ||= []

    def self.floor
      GameObj.loot.to_a.select {|i| i.type.include?("box")}
    end

    def self.can_pick?
      Skills.pickinglocks > Char.level * 2
    end

    def self.picker?
      Config.pickers && GameObj.pcs.find {|pc| Config.pickers.include?(pc.noun)}
    end

    def self.drop()
      Containers.lootsack.where(type: /box/).each { |box|
        box.take
        fput "drop #%s" % box.id
        wait_until {GameObj.loot.map(&:id).include?(box.id)}
        Dropped << box.id
        Dropped.shift while Dropped.size > 100
      }
    end
  end
end