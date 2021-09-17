module Shiva
  module Timer
    def self.await()
      return if Spell[506].active?
      return if Spell[1035].active?
      ttl = (checkrt - 1.5)
      if ttl > 0
        slept = sleep(ttl)
        Log.out("estimated: #{ttl} -> actual: #{slept}", label: :latency)
      end
    end
  end
end