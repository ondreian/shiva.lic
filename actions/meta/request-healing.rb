module Shiva
  class RequestHealing < Action
    def priority
      Priority.get(:high) - 1
    end

    def available?
      Char.total_wound_severity > 0 and
      Team.has_healer?
    end

    def apply()
      ttl = Time.now + 3
      Team.request_healing
      wait_while("waiting on blood...") {percenthealth < 100 && Time.now < ttl} unless Effects::Debuffs.active?("Condemn")
      wait_while("waiting on cutthroat") {cutthroat? && Time.now < ttl} if cutthroat?
    end
  end
end