require "benchmark"
require "rexml/document"

module Shiva
  module Bandits
    ##
    ## Cache so room lookups are not glacially slow
    ##
    module Cache
      @store ||= {}

      def self._raw
        @store
      end

      def self.save_to_disk()
        :noop
      end

      def self.lookup(key, fallback = nil)
        _raw.fetch(key.to_sym, fallback)
      end

      def self.put(key, val)
        write = {}
        write[key.to_sym] = val
        @store = _raw.merge(write)
        Cache.save_to_disk()
      end

      def self.memoize(key)
        cached = lookup(key, nil)
        return cached unless cached.nil?
        Cache.put(key, yield)
        Log.out("Key(#{key})", label: %i[cache insert])
        cached = lookup(key)
      end

      if Opts["flush-cache"]
        Log.out("flushing cache", label: %i[cache flush])
        Settings[:cache] = {}
        Settings.save()
        exit
      end

      if Opts.cache
        Log.out(Cache._raw, label: %i[cache state])
        exit
      end
    end

    module Filter
      def self.is_blacklisted?
        return -> r { BLACKLIST.include?(r.id) }
      end

      def self.is_string_proc?
        return -> kv {
          (id, movement) = kv
          #Log.out([id, movement], label: %i[is_string_proc])
          movement.is_a?(StringProc) or not Room[id].location.include?(Bounty.area.split(" ").take(2).join(" ")) 
        }
      end

      def self.is_valid_room?
        return -> r {
          r.location.is_a?(String) && (r.location.eql?(Bounty.area) or 
          r.location.include?(Bounty.area.split(" ").take(2).join(" "))) and 
          not r.wayto.to_a.all?(&Filter.is_string_proc?) 
        }
      end
    end

    @cooldown ||= []

    def self.cooldown
      @cooldown
    end

    def self.candidates(way_hash, ids)
      all_candidates = way_hash.to_a.select do |id, movement| movement.is_a?(String) end
      return all_candidates if all_candidates.size.eql?(1)
      with_cooldown = all_candidates.select do |id, movement| (ids - @cooldown.map(&:first)).include?(id.to_i) end
      return with_cooldown unless with_cooldown.empty?
      return all_candidates
    end

    def self.poll_bandits!
      10.times {break if bandit_count>0; sleep 0.1} if Claim.current?
    end

    def self.ensure_none_hiding()
      return unless Group.nonmembers.empty?
      ttl = Time.now + [2, Opts.to_h.fetch(:ttl, Group.members.size).to_i].min
      wait_while { Time.now < ttl and Creatures.bandit.empty? }
    end
    
    @bandit_count = 0

    def self.set_bandit_count(n: 0, label:)
      Log.out("setting bandit count(#{n})", label: label) if n != @bandit_count
      @bandit_count = n
    end

    def self.bandit_count()
      @bandit_count + Creatures.bandit.size
    end

    def self.hidden_bandit_count()
      @bandit_count - Creatures.bandit.size
    end

    def self.ingest_dialog_data(dialog)
      #Log.out(dialog, label: :dialog)
      menu = REXML::Document.new(dialog.downcase).root.elements["dropdownbox"]
      return unless menu
      content_text = menu.attributes["content_text"]
      return unless content_text
      bandits = content_text.split(",").select { |m| m =~ GameObj.type_data["bandit"][:name] }
      set_bandit_count(n: bandits.size, label: %i(dialog_data))
    end

    def self.add_bandit_hook()
      #bandit_noun_regex = /bandit|brigand|robber|thug|thief|rogue|outlaw|mugger|marauder|highwayman/
      #combat_dialog_regex = /<dialogData id='combat'>.*content_text="(.*)" content_value=.*<\/dialogData>/
      DownstreamHook.add('bandit_counter', -> line {
        begin
          ingest_dialog_data(line) if line =~ /^<dialogData id='combat'>/
        rescue => exception
          Log.out(exception)
        ensure
          return line
        end
      })

      before_dying do	DownstreamHook.remove('bandit_counter') end
    end

    def self.expose_hidden_bandits()
      return if bandit_count.eql?(0)
      return unless Creatures.bandit.empty?
      Log.out("detected hidden bandits", label: %i[bandits hidden])
      return fput "symbol of sleep" if Society.status.include?("Voln") and Society.rank > 21
      return MinorElemental.ewave() if Spell[410].affordable? and Spell[410].known? and not cutthroat?
    end

    DEFAULT_RESTING_IDS = %w(18698) #  + Map.list.select do |r| r.tags.include?("town") end
    def self.rtb()
      return Script.run("widowmaker", "off") if Room.current.title.first.downcase.include?("widowmaker")
      Script.run("ring", Opts.ring.to_s) if Opts.ring
      exit if Opts.bail
      rally(
        Room.current.find_nearest(DEFAULT_RESTING_IDS))
    end

    
    def self.find_entry_point(area)
      combat_zone = self.rooms(area)
      nearest_dangerous_room = Room.current.find_nearest(combat_zone)
      #
      # one step away from the danger-zone for setting up the group
      #
      Room.current.find_nearest(Room[nearest_dangerous_room].wayto.reject do |id, way|
        combat_zone.include?(id)
      end.map(&:first))
    end

    def self.rooms(area)
      Cache.memoize(area) do
        Log.out(%[building candidate room list], label: %i[area])
        list = Room.list.select(&Filter.is_valid_room?).map(&:id)
        Log.out(%[found #{list.size} candidate rooms], label: %i[area])
        list
      end
    end

    def self.crawl(area)
      Char.stand.unhide
      fput "search" if Claim.current? and Kernel::rand > 0.66
      return if bandit_count > 0 && Claim.current?
      waitcastrt?
      waitrt?
      self.poll_bandits!
      return if bandit_count > 0 && Claim.current?
      candidates_for_crawling = Bandits.candidates(Room.current.wayto, self.rooms(area)).map(&:last)
      Move.rand(candidates_for_crawling, peer: true) {self.bandit_count > 0}
      @cooldown << [Room.current.id, Time.now + 10]
      @cooldown.select! {|id, ttl| ttl < Time.now}
    end

    Cache.memoize("Widowmaker's Road") { (29021..29030).to_a }
  end
end