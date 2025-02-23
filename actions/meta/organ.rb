module Shiva
  class Organ < Action
    # With a creaking sound that echoes through the area, the air bladders of the pipe organ finish filling.  The organ can be played once more.
    DownstreamHook.add("shiva/organ", -> line {
      if line.eql?(%[With a creaking sound that echoes through the area, the air bladders of the pipe organ finish filling.  The organ can be played once more.])
        Organ.end_cooldown
      end
      return line
    })

    before_dying {
      DownstreamHook.remove("shiva/organ")
    }

    def self.end_cooldown
      Settings[:organ_cooldown] = nil
    end

    def priority
      Priority.get(:high) - 10
    end

    def cooldown?
      return false if Settings[:organ_cooldown].nil?
      Time.now < Settings[:organ_cooldown]
    end

    def available?
      return false
      not Effects::Buffs.active?("Sword Hymn") and
      @env.name.to_s.include?("moonsedge") and 
      not self.cooldown?
    end

    module Outcomes
      Ok  = %r{Your spirits are bolstered by the victorious melody!}
      Cooldown = %r{You'll have to wait for them to finish recovering from the organ's last performer before you can play.}
      All = Regexp.union(Ok, Cooldown)
    end

    def apply
      Char.unhide if hidden?
      Script.run("go2", "u4577213")
      result = dothistimeout("play organ", 5, Outcomes::All)
      case result
      when Outcomes::Ok, Outcomes::Cooldown
        Settings[:organ_cooldown] = Time.now + 60 * 20
      end
    end
  end
end