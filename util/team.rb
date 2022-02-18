module Shiva
  module Team
    HEALERS    = %w(Pixelia Dithio Scarface)
    SKINNNERS  = %w(Pixelia)

    @expiry = Time.now

    def self.available_skinners()
      (GameObj.pcs.to_a.map(&:noun) & SKINNNERS).select do |skinner|
        Cluster.alive?(skinner)
      end
    end

    def self.available_healers()
      (GameObj.pcs.to_a.map(&:noun) & HEALERS).select do |healer|
        Cluster.alive?(healer)
      end
    end

    def self.random_healer()
      return unless Team.has_healer?
      yield Team.available_healers.sample if block_given?
    end

    def self.random_skinner()
      Log.out(Team.available_skinners)
      return if Team.available_skinners.empty?
      yield Team.available_skinners.sample if block_given?
    end

    def self.has_healer?
      Team.available_healers.size > 0
    end

    def self.request_healing()
      return :too_soon unless Time.now > @expiry
      random_healer do |healer|
        Log.out("requesting healing from %s" % healer, label: %i(team heal))
        @expiry = Time.now + 5
        Cluster.request(healer, channel: :heal)
      end
      ttl = Time.now + 5
      wait_while("waiting on blood...") {percenthealth < 100 && Time.now < ttl}
      wait_while("waiting on cutthroat") {cutthroat? && Time.now < ttl} if cutthroat?
    end

    def self.request_mana(mana = nil)
      return :too_soon unless Time.now > @expiry
      random_healer do |healer|
        @expiry = Time.now + 30
        return Cluster.request(healer, 
          channel: :mana, 
          mana: mana)
      end
    end

    def self.request_skinning(ids)
      return if ids.empty?
      Log.out(ids, label: :request_skin)
      random_skinner do |skinner|
        return Log.out(
          Cluster.request(skinner, 
            **ids.merge({
              channel: :skin,
              timeout: 8})))
      end
    end
  end
end