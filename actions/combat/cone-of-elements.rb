module Shiva
  class ConeOfElements < Action
    def priority
      80
    end

    def available?(foe)
      Lich::Claim.mine? and
      self.env.foes.size > 1 and
      not foe.nil? and
      not foe.name.include?("Vvrael") and
      Spell[518].known? and
      Spell[518].affordable? and
      checkmana > 20 and
      Wounds.nsys < 2 and
      self.env.foes.reject {|f| f.name =~ /vvrael|crawler/i}.map(&:status).select(&:empty?).size > 1
    end

    def apply(foe)
      fput "stance off\rincant 518\rstance guard" % foe.id
      if Spell[515].active?
        sleep 0.5
      else
        waitcastrt?
      end
    end
  end
end