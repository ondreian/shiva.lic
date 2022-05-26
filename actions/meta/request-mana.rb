module Shiva
  class RequestMana < Action
    def priority
      3
    end

    def available?
      percentmana < 70 and
      Team.has_healer? and
      %w(Bard).include?(Char.prof) and
      (@ttl && Time.now > @ttl)
    end

    def apply()
      @ttl = Time.now + 10
      Team.request_mana
    end
  end
end