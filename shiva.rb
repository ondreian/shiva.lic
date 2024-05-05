require_relative "./config"

module Shiva
  def self.root()
    File.join Dir.home, "gemstone", "shiva"
  end

  def self.import(file)
    load File.join(self.root, file)
  end

  def self.highest_priority_files
    Dir[File.join(self.root, "util", "**", "*.rb")]
  end

  def self.files
    Dir[File.join(self.root, "**", "*.rb")]
      .sort {|f| f.include?("environments") ? -1 : 1} + self.highest_priority_files
  end

  def self.load_all_modules
    self.files.reverse.each { |asset|
      #Log.out("load >> %s" % asset)
      load(asset) 
    }
    Log.out "loaded %s files" % files.size
  end

  def self.reload_actions(verbose: false)
    Shiva::Trash.reload
    Dir[File.join(self.root, "actions", "**", "*.rb")]
      .each {|asset|
        load(asset)
        Log.out "loaded %s" % asset, label: %i(load) if verbose
      }
  end

  def self.cleanup!
    before_dying {
      %w(eloot go2).each {|s| Script.kill(s) if Script.running?(s)}
    }
  end

  def self.run_once(env_name)
    controller = Shiva::Controller.new()
    controller.set_env(env_name)
    $shiva = controller
    controller.run()
  end

  def self.run(env_name)
    loop {
      self.run_once(env_name)
      break if $shiva_graceful_exit
      break unless Opts["daemon"]
      sleep 0.1
    }
  end

  def self.simulate
    Shiva.load_all_modules
    controller = Shiva::Controller.new Opts["env"]
    loop do
      sleep 0.1
      action = controller.best_action
      next if action.eql?(:noop)
      Log.out("would have used -> %s" % action.class.name, 
        label: %i(simulate))
      wait_while {controller.best_action.eql?(action)}
    end
  end

  def self.town()
    return Opts["town"] if Opts["town"]
    return Config.town if Config.town
    town_id = Room.current.find_nearest_by_tag("town")
    fail "could not find the nearest town" if town_id.nil?
    Room[town_id].location
  end

  def self.environments(town)
    Environment::All.select {|env| 
      env.town && town.downcase.to_s.downcase.include?(env.town.downcase)
    }
  end

  def self.best_env(town = self.town)
    candidate_environments = self.available_environments()
    creature = Bounty.task.creature
    fail "did not find a matching environment for level=%s" % Char.level if available_environments.empty?
    return candidate_environments.sample if creature.nil?
    creature_noun = creature.split.last
    matching_environments = candidate_environments.select {|env| env.native_foes.include?(creature_noun)}
    fail "did not find a matching environment for #{creature}" if matching_environments.empty?
    matching_environments.sample
  end

  def self.hunt(env: self.best_env, resume: false)
    Shiva::State.bounty_attempts_increment
    self.preflight!
    env_name = env.name
    if resume
      Log.out("resuming %s" % env_name, label: %i(env resume))
    else
      _respond "<b>hunting in %s</b>" % env_name
      Log.out(Shiva::State.bounty_attempts, label: %i(bounty attempts))
    end
    self.run_once(env_name)
  end

  def self.task
    Task.advance self.town
  end

  def self.handle_drop_bad_bounty!
    return unless %i(skin gem).include?(Bounty.type)
    return if Task.cooldown?
    Bounty.remove if Opts["drop"]
  end

  def self.bounty!
    self.handle_drop_bad_bounty!

    case Bounty.type
    when :succeeded, :report_to_guard, :failed, :get_heirloom, :creature_problem, :get_skin_bounty, :get_bandits, :heirloom_found
      self.task
    when :none
      self.task unless Task.cooldown?

      if Config.bounty_boost && Bounty.type.eql?(:none) and Task.cooldown? and ::EBoost.bounty.available? and Effects::Cooldowns.to_h.dig("Next Bounty") - Time.now > (60 * 7.5) and Script.exists?("use-boost-bounty") and Config.use_boost? and !Mind.saturated?
        Script.run("use-boost-bounty")
      else
        self.hunt if Bounty.type.eql?(:none)
      end
    when :dangerous, :cull, :heirloom, :skin, :gem
      self.hunt
    when :herb
      if %w(Moonsedge).include?(Bounty.area)
        Bounty.remove
      else
        fail "eforage.lic not detected to run herb tasks" unless Script.exists?("eforage")
        # previous_task = checkbounty
        Script.run("eforage", "--bounty")
        self.task
      end
    when :bandits
      if %(rogue warrior).include? Char.prof.downcase
        self.bandits
      else
        Bounty.remove
      end
    when :escort
      self.escort(self.town)
    when :rescue
      Bounty.remove
    else
      fail "shiva/auto not implemented for %s" % Bounty.type
    end
  end

  def self.available_environments
    self.environments(self.town).select {|env| 
      env.level.include?(Char.level)
    }.reject {|env|
      Config.environs_drop.include?(env.name.to_s)
    }
  end

  def self.handle_conditions!
    Boost.experience
    Conditions::Cutthroat.handle!
    Conditions::Saturated.handle! unless Boost.loot?
    Conditions::Overexerted.handle!
    Conditions::Burrowed.handle!
    Conditions::Hypothermia.handle!
  end

  def self.handle_room_desc!
    fput "flag desc off"
    before_dying {fput "flag desc on"}
  end

  def self.stockpile_gems!
    return :noop if Config.gems.empty?
    return :noop if Config.stockpile_bots.empty?
    return unless Script.exists?("give")
    bot = GameObj.pcs.select {|pc| Config.stockpile_bots.include?(pc.name) }.sample
    return :no_bots if bot.nil?
    Config.gems.each {|gem|
      Log.out("giving all %s -> %s" % [gem, bot.name], label: %i(gem storage))
      Script.run("give", "all %s %s" % [gem, bot.name])
    }
  end

  def self.preflight!
    fail "no environments found for #{self.town}" if self.available_environments.empty?
    respond "{town=%s, environs=%s}" % [self.town, self.available_environments.map(&:name).join(",")]
    return if available_environments.any?(&:current?)
    Base.go2
    Log.out(":preflight! returned to base")
    self.stockpile_gems!
    Script.run("waggle", "--stop-at=1")
    self.handle_conditions!
  end

  def self.down!(msg = nil)
    Base.go2
    _respond "<b>%s</b>" % msg if msg.is_a?(String)
    exit
  end

  def self.state
    Shiva::State.get
  end

  def self.daemon?
    Log.out("{graceful_exit=%s, daemon=%s}" % [$shiva_graceful_exit, Opts["daemon"]], label: %i(daemon?))
    self.down!("shutting down because of graceful_exit...") if $shiva_graceful_exit
    return if Opts["daemon"]
    self.down! "--daemon flag not detected, exiting...reason=%s" % ($shiva_rest_reason || ":none")
  end

  def self.current_env
    self.available_environments.find(&:current?)
  end

  def self.auto()
    $shiva_graceful_exit = false
    $shiva_rest_reason = nil
    multifput("exp", "bounty", "inven enh on")
    self.cleanup!
    self.handle_room_desc!
    loop {
      Shiva::State.set(:hunting)
      if env_to_resume = self.available_environments.find(&:current?)
        self.hunt(env: env_to_resume, resume: true)
      elsif Mind.saturated? && Bounty.done? && Opts["farm"]
        self.hunt
      elsif Boost.loot?
        self.hunt
      else
        self.bounty!
      end
      self.daemon?
    }
  end

  def self.escort(town)
    return Task.drop(town) unless Config.escort.any? {|dest| Bounty.task.destination.downcase.include?(dest) }
    fail "escort script is already running\nso something weird has happened!" if Script.running?("escort")
    Script.run("escort")
  end

  def self.bandits
    self.run_once(:bandits)
  end

  def self.control_room()
    self.run_once(:escort)
  end

  def self.init
    Shiva.load_all_modules
    Script.run("eboost") if Script.exists?("eboost") && !defined?(::EBoost)
    Script.start("effect-watcher") unless Script.running?("effect-watcher")
    if Opts["simulate"]
      Shiva.simulate
    elsif Opts["env"]
      Shiva.run Opts["env"]
    elsif Opts["load"]
      exit
    elsif Opts["environs"]
      Log.out "environs: %s" % self.available_environments.map(&:name).join(", ")
    elsif Opts["detect"]
      previous_town = Config.town
      detected_town = Room[Room.current.find_nearest_by_tag("town")].location
      Config.set "general.town", detected_town
      Log.out "shiva/town was %s -> changed to %s" % [previous_town, detected_town], label: %i(town)
      exit
    elsif Opts["auto"]
      Shiva.auto
    elsif Opts["set"]
      value, key = Script.current.vars.reverse
      Config.set(key, value)
      return Config.show
    elsif Opts["edit"]
      return Script.run("edit", Config.dir.to_s)
    elsif Opts["config"]
      return Config.show
    elsif Opts["environs"]
      return Log.out(self.available_environments.join(", "), label: %i(environs available))
    else
      _respond <<~HELP
        <b>;shiva:</b>

          --env       environment to load
          --simulate  run as a simulation
      HELP
    end
  end

  Shiva.import "action.rb"
  Shiva.import "actions.rb"
end
