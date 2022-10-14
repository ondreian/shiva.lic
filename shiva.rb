

module Shiva
  def self.root()
    File.join Dir.home, "gemstone", "shiva"
  end

  def self.import(file)
    load File.join(self.root, file)
  end

  def self.load_all_modules
    Dir[File.join(self.root, "**", "*.rb")].sort {|f| -f.size}.reverse
      .each {|asset|
        load(asset)
        Log.out "loaded %s" % asset, label: %i(load)
      }
  end

  def self.reload_actions(verbose: false)
    Shiva::Trash.reload
    Dir[File.join(self.root, "actions", "**", "*.rb")]
      .each {|asset|
        load(asset)
        Log.out "loaded %s" % asset, label: %i(load) if verbose
      }
  end

  def self.run_with_env(env_name)
    Shiva.load_all_modules
    controller = Shiva::Controller.new()
    controller.set_env(env_name)
    $shiva = controller
    controller.run()
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
    town_id = Room.current.find_nearest_by_tag("town")
    fail "could not find the nearest town" if town_id.nil?
    Room[town_id].location
  end

  def self.auto()
    Shiva.load_all_modules
    closest_town = self.town
    available_environments = Environment::All.select {|env| env.town.eql?(closest_town)}
    fail "no environments found for #{closest_town}" if available_environments.empty?
    respond "{town=%s, environs=%s}" % [closest_town, available_environments.map(&:name).join(",")]
    Task.advance(closest_town) if Bounty.type.eql?(:none)
    if creature = Bounty.task.creature
      creature_noun = creature.split.last
      matching_environments = available_environments.select {|env| env.foe_nouns.include?(creature_noun)}
      fail "did not find a matching environment for #{creature}" if matching_environments.empty?
      env_name = matching_environments.sample.name
      _respond "<b>hunting in %s</b>" % env_name
      self.run_with_env(env_name)
    else
      fail "shiva/auto not implemented for non-creature tasks"
    end
  end

  def self.init
    if Opts["simulate"]
      Shiva.simulate
    elsif Opts["env"]
      Shiva.run_with_env Opts["env"]
    elsif Opts["load"]
      Shiva.load_all_modules
    elsif Opts["auto"]
      Shiva.auto
    elsif Opts["sell"]
      Shiva.load_all_modules
      Task.advance($shiva.env.town) if $shiva and %i(gem skin).include?(Bounty.type) and not Task.sellables.empty?
      Shiva::Teardown.new(OpenStruct.new({env: nil})).sell_loot
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
