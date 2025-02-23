module Shiva
  module Task
    module Rare
      Gems = /platinum fang|metallic black pearl|faceted black diamond|chalky yellow cube|urglaes|aster opal|doomstone|shadowglass orb|wyrdshard|thunderstone$/
    end

    @last_expedite_expiry = Time.now

    def self.log()
      Log.out(Bounty::Util.short_bounty, label: %i(bounty current))
    end

    def self.waiver!
      return if Effects::Buffs.active?("Bounty Waiver")
      return unless defined? EBoost
      return unless EBoost.waiver.available?
      #EBoost.waiver.use
    end

    def self.expedites?
      return false
      defined? BountyHUD and BountyHUD.session.dig(:expedites) > 0
    end

    def self.cycle(town)
      Bounty.remove
      return if not self.expedites? or Mind.saturated? or @expiry_cooldown
      self.log()
      Task.waiver!
      outcome = dothistimeout("ask #%s for exp" % Bounty.npc.id, 4, Regexp.union(
        %r[I'll expedite your task reassignment.],
        %r[I can't expedite this task reassignment]))
      @expiry_cooldown = true if outcome =~ /can't/
        
      @last_expedite_expiry = Time.now + (15 * 60)
    end

    def self.room(town, tag)
      Log.out("{town=%s, tag=%s}" % [town, tag], label: %i(town tag))
      World.tag_for_town(town, tag) or fail "could not find #{tag} for : #{town}"
      #World.by_town(tag).find {|k, v| k.include?(town)}.last or fail "could not find #{tag} for : #{town}"
    end

    def self.sell_by_tag(town, tag, sellable)
      sellables = Task.sellables
      return :none if sellables.empty?
      shop = self.room(town, tag)
      shop.id.go2
      empty_hands
      will_be_completed = sellables.size >= Bounty.number
      sellables.each {|g|
        g.take
        fput "sell #%s" % g.id
      }
      fill_hands
      return unless will_be_completed
      self.advance(town)
    end

    def self.drop(town)
      self.cycle(town)
      self.advance(town)
    end

    def self.cooldown?
      Effects::Cooldowns.active?("Next Bounty")
    end

    def self.find_guard_with_retry(tries: 0)
      fail "could not find guard" if tries > 10
      begin
        Bounty.find_guard
      rescue Exception => _exception
        sleep 5
        self.find_guard_with_retry(tries: tries + 1)
      end
    end

    def self.ask_guildmaster_for_bounty
      Task.waiver!
      Bounty.ask_for_bounty
    end

    def self.auto()
      self.advance Shiva::Config.town
    end

    def self.allowed?(allowed_list = Config.bounty_allowed_list)
      return true if allowed_list.empty?
      case Bounty.type
      when :none, :failed, :succeeded, :report_to_guard, :heirloom_found
        true
      when  :creature_problem
        allowed_list.include?(:dangerous) or allowed_list.include?(:cull)
      when :get_bandits, :bandits
        allowed_list.include?(:bandits)
      when :gem, :get_gem_bounty
        allowed_list.include?(:gem)
      when :get_skin_bounty, :skin
        allowed_list.include?(:skin)
      when :rescue, :get_rescue
        allowed_list.include?(:rescue)
      when :heirloom, :get_heirloom
        allowed_list.include?(:heirloom)
      when :dangerous
        allowed_list.include?(:dangerous)
      when :cull
        allowed_list.include?(:cull)
      when :herb, :get_herb_bounty
        allowed_list.include?(:herb)
      when :get_escort, :escort
        allowed_list.include?(:escort)
      else
        fail "Bounty(#{Bounty.task.type}) / could not match"
      end
    end

    def self.advance(town)
      guild = self.room(town, "advguild")
      guild.id.go2
      self.log()
      return self.drop(town) unless Task.allowed?
      sleep 0.2
      case Bounty.type
      when :none, :failed
        return :cooldown if self.cooldown? and not self.expedites?
        return :saturated if Mind.saturated? and self.cooldown?
        self.cycle(town) if self.cooldown? and self.expedites?
        self.ask_guildmaster_for_bounty
        self.advance(town)
      when :get_rescue, :creature_problem, :get_heirloom, :report_to_guard, :get_bandits
        self.room(town, "advguard").id.go2
        Task.find_guard_with_retry
        Bounty.ask_for_bounty
        self.advance(town)
      when :succeeded
        return :saturated if Mind.saturated?
        guild.id.go2
        Axp.apply { Bounty.ask_for_bounty }
        return :waiting if Time.now < @last_expedite_expiry
        self.advance(town)
      when :gem
        return self.sell_by_tag(town, "gemshop", Bounty.task.gem) if Bounty.task.gem !~ Rare::Gems
        self.drop(town)
      when :get_skin_bounty
        self.room(town, "furrier").id.go2
        Bounty.ask_for_bounty
        self.advance(town)
      when :get_gem_bounty
        self.room(town, "gemshop").id.go2
        Bounty.ask_for_bounty
        self.advance(town)
      when :skin
        return self.sell_by_tag(town, "furrier", Bounty.task.skin.slice(0..-2))
      when :rescue
        guild.id.go2
        self.drop(town)
      when :heirloom
        return :ok unless (Bounty.creature =~ /(monstrosity|assassin|warden)$/ || checkbounty =~ /SEARCH the area until you find it/)
        guild.id.go2
        self.drop(town)
      when :dangerous
        return :ok unless Bounty.creature =~ /(monstrosity|assassin|warden)$/
        guild.id.go2
        self.drop(town)
      when :cull
        return :ok unless Bounty.creature =~ /(monstrosity|assassin|warden)$/
        guild.id.go2
        self.drop(town)
      when :heirloom_found
        self.room(town, "advguard").id.go2
        Task.find_guard_with_retry
        heirloom = Containers.lootsack.where(name: /#{Bounty.task.heirloom}/).first
        fail "could not find #{Bounty.task.heirloom}" if heirloom.nil?
        empty_hands
        heirloom.take
        fput "give #%s" % Bounty.npc.id
        ttl = Time.now + 5
        wait_while {Bounty.type.eql?(:heirloom_found) and Time.now < ttl}
        fail "error / happened while turning in #{Bounty.task.heirloom}" if Time.now > ttl
        fill_hands
        self.advance(town)
      when :get_herb_bounty
        return self.drop(town) if town =~ /kraken/i
        tag = town =~ /hinterwilds/i ? "healer" : "npchealer"
        self.room(town, tag).id.go2
        Bounty.ask_for_bounty
        self.advance(town)
      when :escort, :bandits
        return :ok
      when :herb
        return self.drop(town) if town =~ /kraken/i
        return self.drop(town) if Bounty.herb =~ /fleshbulb|fleshbinder|fleshsore/
        herbs = Containers.lootsack.where(name: Bounty.herb).take(Bounty.number)
        return :ok if herbs.empty?
        tag = town =~ /hinterwilds/i ? "healer" : "npchealer"
        self.room(town, tag).id.go2
        empty_hands
        herbs.each {|h|
          current_state = checkbounty
          h.take
          fput "give #%s" % Bounty.npc.id
          ttl = Time.now + 3
          wait_while {checkbounty.eql?(current_state) && Time.now < ttl}
          fail "unhandled herb issue" if Time.now > ttl
        }

        fill_hands

        self.advance(town) if Bounty.type.eql?(:succeeded)
      else
        fail "Bounty(#{Bounty.task.type}) / not implemented"
      end
    end

    def self.sellables
      case Bounty.type
      when :gem
        return Containers.lootsack.select {|i| i.name.end_with?(Bounty.gem) }.take(Bounty.task.number)
      when :skin
        return Containers.lootsack.select {|i| i.name.start_with? Bounty.skin.slice(0..-2) }
      else
        fail "invalid Task.sellable/0 usage"
      end
    end

    def self.can_complete?
      case Bounty.type
      when :heirloom_found
        return Containers.lootsack.where(name: /#{Bounty.task.heirloom}/).size > 0
      when :report_to_guard, :succeeded
        return true
      when :gem
        return Task.sellables.size >= Bounty.task.number
      when :skin
        return self.skin_bounty_complete?
      else
        false
      end
    end

    def self.skin_bounty_complete?
      return Task.sellables.size >= Bounty.task.number if (Skills.survival + Skills.firstaid) > Char.level * 3

      if %w(fine).include?(Bounty.quality)
        Task.sellables.size >= (Bounty.task.number * 4)
      else
        Task.sellables.size >= (Bounty.task.number * 2)
      end
    end

    def use_waiver
      return unless defined?(Boost)
      return unless Boost.waiver.available > 0
      Effects::Buffs
    end
  end
end