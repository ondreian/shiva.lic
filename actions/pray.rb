module Shiva
  class Pray < Action
    def initialize(env)
      @count = 0
      super(env)
    end

    def priority
      3
    end

    def prayed
      @count
    end

    def reset
      @count = 0
    end

    def max_prayers
      return 3 if Group.empty?
      Group.size + 2
    end

    def available?
      self.env.name.eql?(:duskruin) and
      self.needs_resource? and
      @count < self.max_prayers
    end

    def needs_resource?
      percentstamina < 10 or
      percentmana < 50
    end

    def apply
      fput "pray"
      @count = @count + 1
    end
  end
end