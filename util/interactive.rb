module Shiva
  module Interactive
    def self.system_notification(msg)
      return unless defined? Notify
      if Notify::Sounds.to_a.grep(/small_heart/) 
        Notify::Sounds.play("small_heart")
      else
        Notify::Sounds.play Notify::Sounds.to_a.sample
      end
      Notify.show(body: msg)
    end

    def self.capture(msg, pattern)
      _respond "<b>%s</b>" % msg
      self.system_notification(msg)
      while line = get 
        return line if line.strip =~ pattern
      end
    end
  end
end