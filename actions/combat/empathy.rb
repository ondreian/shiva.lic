module Shiva
  class Empathy < Action
    def priority
      10
    end

    def available?(foe)
      not foe.nil? and
      not foe.name.include?("Vvrael") and
      foe.name =~ /brawler/ and
      foe.status.empty? and
      Spell[1108].known? and
      Spell[1108].affordable?
    end

    def apply(foe)
      fput "prep 1108\rcast #%s" % foe.id
      waitcastrt?
    end
  end
end