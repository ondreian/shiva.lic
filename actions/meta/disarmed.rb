module Shiva
  class Disarmed < Action
    NAME     = "shiva/disarm-watcher"
    Pattern  = %r{\[Use the RECOVER ITEM command while in the appropriate room to regain your item.\]}
    @@room   = nil

    def self.register()
      Shiva::Hook.register(:disarmed) do
        Shiva::Disarmed.parse(str)
      end
    end

    def self.parse(str)
      if result = str.start_with?(Pattern)
        Disarmed.active(XMLData.room_id)
      end
    end
  
    def self.active(room)
      @@room = room
      self
    end
  
    def self.active?
      !@@room.nil?
    end
  

    def priority
      Priority.get(:high) - 1_000
    end

    def available?
      Disarmed.active?
    end

    def notify
      return unless defined? Notify
      Notify::Sounds.play %[low_health]
      Notify.notify(body: "You have been disarmed", 
        type: :disarmed, 
        from: :shiva)
      Notify::Sounds.play %[low_health]
    end

    def apply
      Base.go2
      10.times {_respond "<b>You have been disarmed in room=#{@@room}</b>"}
      self.notify
      exit
    end
  end

  Disarmed.register()
end