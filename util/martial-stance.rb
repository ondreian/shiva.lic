module Shiva
  module Martial
    module Stance
      def self.use(name, cmd)
        return if name.eql?(:noop)
        return if Effects::Spells.active?(name)
        put "cman %s" % cmd
      end

      def self.offensive_martial_stance()
        return ["Whirling Dervish", "dervish"] if CMan.whirling_dervish && $shiva.env.foes.size > 1 && GameObj.left_hand.type.include?("weapon")
        return ["Predator's Eye", "predator"]  if CMan.predators_eye > 0
        return [:noop, nil]
      end

      def self.defensive_martial_stance()
        return ["Slippery Mind", "slippery"] if CMan.slippery_mind > 0
        return ["Duck and Weave", "duck"]    if CMan.duck_and_weave > 0
        return [:noop, nil]
      end

      def self.swap()
        self.use(*self.offensive_martial_stance)
        yield
        self.use(*self.defensive_martial_stance)
      end
    end
  end
end