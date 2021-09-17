module Shiva
  class Hide < Action
    PERCEPTIVE = %w(ursian lion griffin)

    def priority
      if @env.foes.any? {|foe| PERCEPTIVE.include?(foe.noun) }
        1_000
      else
        5
      end
    end

    def env?
      return false if Group.leader? and not Group.empty?
      return false if @env.name.eql?("Bandits") and not Group.empty?
      return false if @env.name.eql?("Osa")
      return @env.foes.size > 0 if @env.name.eql?("Bandits")
      return true
    end

    def available?
      Skills.stalkingandhiding > (Char.level * 2) and
      not Effects::Debuffs.active?("Jaws") and
      not hidden? and
      not Opts["open"] and
      env?
    end

    def apply()
      Timer.await()
      fput "hide"
    end
  end
end