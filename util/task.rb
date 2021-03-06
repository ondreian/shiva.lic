module Task
  @last_expedite_expiry = Time.now

  def self.log()
    Log.out(Bounty::Util.short_bounty, label: %i(bounty current))
  end

  def self.expedites?
    defined? BountyHUD and BountyHUD.session.dig(:expedites) > 0
  end

  def self.cycle(town)
    Bounty.remove
    return if not self.expedites? or Mind.saturated?
    self.log()
    dothistimeout("ask #%s for exp" % Bounty.npc.id, 4, %r[I'll expedite your task reassignment.])
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

  def self.advance(town)
    guild = self.room(town, "advguild")
    guild.id.go2
    self.log()
    sleep 0.2
    case Bounty.type
    when :none
      return :cooldown if Effects::Cooldowns.active?("Next Bounty") and not self.expedites?
      return :saturated if Mind.saturated? and Effects::Cooldowns.active?("Next Bounty")
      self.cycle(town) if Effects::Cooldowns.active?("Next Bounty") and self.expedites?
      Bounty.ask_for_bounty
      self.advance(town)
    when :get_rescue, :creature_problem, :get_heirloom, :report_to_guard
      self.room(town, "advguard").id.go2
      Bounty.find_guard
      Bounty.ask_for_bounty
      self.advance(town)
    when :succeeded
      return :saturated if Mind.saturated?
      guild.id.go2
      Bounty.ask_for_bounty
      return :waiting if Time.now < @last_expedite_expiry
      self.advance(town)
    when :gem
      return self.sell_by_tag(town, "gemshop", Bounty.task.gem) if Bounty.task.gem !~ /chalky yellow cube|urglaes|aster opal|doomstone|shadowglass orb|wyrdshard/
      self.cycle(town)
      return self.advance(town)  
    when :get_skin_bounty
      self.room(town, "furrier").id.go2
      Bounty.ask_for_bounty
      self.advance(town)
    when :get_gem_bounty
      self.room(town, "gemshop").id.go2
      Bounty.ask_for_bounty
      self.advance(town)
    when :skin
      return self.sell_by_tag(town, "furrier", Bounty.task.skin.slice(0..-2)) if Bounty.task.skin !~ /lich finger bones|rift crawler/
      self.cycle(town)
      self.advance(town)
    when :get_bandits, :rescue
      guild.id.go2
      self.cycle(town)
      self.advance(town)
    when :dangerous, :cull, :heirloom
      return :ok unless Bounty.creature =~ /(lich|crusader|crawler|monstrosity)$/
      guild.id.go2
      self.cycle(town)
      self.advance(town)
    when :heirloom_found
      self.room(town, "advguard").id.go2
      Bounty.find_guard
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
    when :escort, :get_herb_bounty
      guild.id.go2
      self.cycle(town)
      self.advance(town)
    else
      fail "Bounty(#{Bounty.task.type}) / not implemented"
    end
  end

  def self.sellables
    case Bounty.type
    when :gem
      return Containers.lootsack.select {|i| i.name.end_with?(Bounty.gem) }
    when :skin
      return Containers.lootsack.where(name: Bounty.skin.slice(0..-2))
    else
      fail "invalid Task.sellable/0 usage"
    end
  end

  def self.can_complete?
    case Bounty.type
    when :report_to_guard, :heirloom_found, :succeeded
      return true
    when :gem, :skin
      return Task.sellables.size >= Bounty.task.number
    else
      false
    end
  end
end