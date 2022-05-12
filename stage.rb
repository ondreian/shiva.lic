module Shiva
  class Stage
    def initialize(env)
      @env = env
    end

    def foe
      self.foes.first
    end
  end
end