module Shiva
  class Web < Action
    def priority
      8
    end

    def available?(foe)
      not foe.nil? and
      not foe.name.include?("Vvrael") and
      foe.name =~ /brawler/ and
      foe.status.empty? and
      Spell[118].known? and
      Spell[118].affordable? and
      %w(Cleric Empath).include?(Char.prof)
    end

    def apply(foe)
      fput "prep 118\rcast #%s" % foe.id
      waitcastrt?
    end
  end
end