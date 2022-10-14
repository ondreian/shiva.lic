module Shiva
  class Bind < Action
    def priority
      7
    end

    def available?(foe)
      not foe.nil? and
      not foe.name.include?("Vvrael") and
      foe.name =~ /psionicist|brawler/ and
      foe.status.empty? and
      Spell[214].known? and
      Spell[214].affordable?
    end

    def apply(foe)
      fput "prep 214\rcast #%s" % foe.id
      waitcastrt?
    end
  end
end