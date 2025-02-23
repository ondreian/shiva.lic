module Shiva
  Environment.define :sanctum do
    @entry      = 25172
    @boundaries = %w(25177 25158 25231)
    @town       = %[Solhaven]
    @scripts    = %w(reaction)
    @foes       = %w(shaper sidewinder sentinel fanatic lurk)
    @level      = (95..105)

    def self.before_main
      #Boost.loot
    end

    def self.before_teardown
      Go2.town
    end
  end
end