module Shiva
  class Environment
    attr_reader :actions, :name, :namespace, :stage,
                :setup, :main, :teardown,
                :last_action, :seen

    attr_accessor :area, :state

    def initialize(name)
      @name      = name.capitalize
      @namespace = Shiva.const_get(@name)
      @stage     = :unknown
      @area      = Opts["area"] || Bounty.task.area
      @seen      = []
      @state     = nil
    end

    def is?(other)
      @namespace.eql?(other)
    end

    def start_scripts(scripts)
      scripts.each {|script| Script.start(script)}
      before_dying {scripts.each {|script| Script.kill(script)}}
    end

    def foes
      return @main.foes if @main.respond_to?(:foes)
      return Foes
    end

    def reset!
      @actions  = Actions.create_for_env(self)
      @main     = @namespace.const_get(:Main).new(self)
      @teardown = @namespace.const_get(:Teardown).new(self)
      @setup    = @namespace.const_get(:Setup).new(self)
    end

    def load
      Log.out File.join __DIR__, "environments", @name.downcase
    end

    def best_action(foe)
      proposed_action = Shiva::Actions.best_action(@actions, foe)
      Log.out(proposed_action.is_a?(Symbol) ? proposed_action : proposed_action.class.name, 
        label: %i(proposed action)) unless proposed_action == @last_action
      @last_action = proposed_action
    end

    def action(query)
      @actions.find {|a| a.class.name =~ /#{query}/}
    end

    def setup!
      @stage = :setup
      @setup.apply(self)
      if @setup.respond_to?(:scripts)
        Log.out("starting scripts: %s" % @setup.scripts.join(", "), label: %i(setup scripts))
        self.start_scripts @setup.scripts
      end
    end

    def main!
      @stage = :main
      @main.apply(self)
    end

    def teardown!
      @stage = :teardown
      @teardown.apply(self)
    end

    def apply
      self.reset!
      loop {
        self.setup!
        self.main!
        self.teardown!
        self.reset!
      }
    end
  end
end