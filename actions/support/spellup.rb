module Shiva
  class Spellup < Action
    @tags = %i(setup)

    def priority
      1
    end

    def available?
      not ::Spellup.queue.empty?
    end

    def grouped
      Script.run("spellup")
    end

    def moonsedge
      Stance.guarded
      room = Room.current.id
      32469.go2
      Script.run("spellup")
      room.go2
    end

    def other
      Stance.guarded
      Walk.apply do
        Script.run("spellup")
      end
    end

    def apply(foe)
      Log.out "missing spells: %s" % ::Spellup.queue.map(&:name).join(", ")
      return self.grouped if not Group.empty?
      if %i(moonsedge_castle moonsedge_village).include?(self.env.name)
        self.moonsedge
      elsif %i(escort)
        Script.run("spellup")
      else
        self.other
      end
    end
  end
end