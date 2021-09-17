

module Shiva
  def self.import(file)
    load File.join(LICH_DIR, "shiva", file)
  end

  def self.load_all_modules
    Dir[File.join(LICH_DIR, "shiva", "**", "*.rb")].sort.reverse
      .each {|asset|
        load(asset)
        # Log.out "loaded %s" % asset, label: %i(load)
      }
  end

  def self.reload_actions(verbose: false)
    Dir[File.join(LICH_DIR, "shiva", "actions", "**", "*.rb")]
      .each {|asset|
        load(asset)
        Log.out "loaded %s" % asset, label: %i(load) if verbose
      }
  end

  def self.run_in_env(env_name)
    Shiva.load_all_modules
    env = Shiva::Environment.new(env_name)
    $shiva = env
    env.apply()
  end

  def self.simulate
    Shiva.load_all_modules
    env = Shiva::Environment.new Opts["env"]
    loop do
      sleep 0.1
      action = env.best_action
      next if action.eql?(:noop)
      Log.out("would have used -> %s" % action.class.name, 
        label: %i(simulate))
      wait_while {env.best_action.eql?(action)}
    end
  end

  def self.init
    if Opts["simulate"]
      Shiva.simulate
    elsif Opts["env"]
      Shiva.run_in_env Opts["env"]
    elsif Opts["load"]
      Shiva.load_all_modules
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
