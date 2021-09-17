module Shiva
  class RequestHealing < Action
    def priority
      1
    end

    def available?
      Char.total_wound_severity > 0 and
      Team.has_healer?
    end

    def apply()
      Team.request_healing
    end
  end
end