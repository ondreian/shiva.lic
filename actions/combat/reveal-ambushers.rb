module Shiva
  class RevealAmbusher < Action
    def priority
      Priority.get(:medium) - 2
    end

    def ability?
      Spell[435].known? or
      Spell[410].known?
    end

    def ambusher?
      reget(10).reverse.take_while {|line| !line.start_with?("[")}.any? {|line|
        line =~ /You notice the hiding place of ([a-z\s]+),/
      }
    end

    def available?
      self.ambusher? and
      self.ability? and
      #self.env.foes.empty? and
      Lich::Claim.mine?
    end

    def reveal!
      return Spell[435].cast if Spell[435].known? and Spell[435].affordable?
      return Spell[410].cast if Spell[410].known? and Spell[410].affordable?
    end

    def apply(_foe)
      self.reveal!
      ttl = Time.now + 2
      #Log.out(self.env.foes)
      wait_while("shiva/waiting on reveal") {self.env.foes.empty? and ttl > Time.now}
      Log.out(self.env.foes.size, label: %i(reveal foes))
    end
  end
end