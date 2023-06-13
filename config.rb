require 'toml-rb'
require 'pathname'

module Shiva
  module Config
    @dir = Pathname.new(DATA_DIR + "/shiva/config")

    def self.dir
      @dir
    end

    module Default
      Support = {
        healers: [],
        pickers: [],
      }

      Weapons = {
        ranged: nil,
        main: nil,
        shield: nil,
        offhand: nil,
        thrown: nil,
      }

      Combat = {
        weapons: {},
        flee: ['monstrosity'],
      }

      Experience = {
        instant: 100,
        normal:  5,
      }

      Loot = {
        boost: true
      }

      Stockpile = {
        bots: [],
        gems: [],
        skins: [],
      }

      General = {
        town:      Room[Room.current.find_nearest_by_tag("town")].location,
        scripts:   [],
      }

      BountyConfig = {
        escort: [],
      }

      All = {
        general:   General,
        combat:    Combat,
        support:   Support,
        stockpile: Stockpile,
        exp:       Experience,
        loot:      Loot,
        bounty:    BountyConfig,
      }
    end

    def self.file
      @dir.join(Char.name.downcase + ".toml")
    end

    def self.init!
      FileUtils.mkdir_p @dir
      File.delete(self.file) if Opts.reset && File.exist?(self.file)
      self.save(Default::All) unless File.exist?(self.file)
      self.load!
      self.show if Opts["debug"]
    end

    def self.save(hash)
      File.write self.file, TomlRB.dump(hash)
      self.load!
      Log.out("config updated -> #{@config}")
    end

    def self.show
      Log.out(@config)
    end

    def self.load!
      @config = TomlRB.load_file(self.file, symbolize_keys: true) 
    end

    def self.set(path, value)
      path = path.split(".")
      root = @config
      assignable_key = path.pop
      path.each {|k| root = root[k.to_sym] }
      root[assignable_key.to_sym] = value
      self.save(@config)
    end

    def self.get(path)
      path.to_s.split(".").reduce(@config) {|acc, k| acc[k.to_sym] }
    end

    def self.town()
      self.get("general.town")
    end

    def self.bases()
      self.get("general.bases")
    end

    def self.scripts
      self.get("general.scripts")
    end

    def self.pickers
      self.get("support.pickers")
    end

    def self.healers
      self.get("support.healers")
    end

    def self.flee
      self.get("combat.flee")
    end

    def self.stockpile_bots
      self.get("stockpile.bots")
    end

    def self.gems
      self.get("stockpile.gems")
    end

    def self.exp
      self.get("exp.normal")
    end

    def self.axp
      self.get("exp.instant")
    end

    def self.escort()
      self.get("bounty.escort")
    end

    def self.main_weapon
      self.get("combat.weapons.main")
    end

    def self.skinning_weapon
      self.get("combat.weapons.skinning")
    end

    def self.offhand_weapon
      self.get("combat.weapons.offhand")
    end

    def self.shield
      self.get("combat.weapons.shield")
    end

    def self.ranged_weapon
      self.get("combat.weapons.ranged")
    end

    def self.thrown_weapon
      self.get("combat.weapons.thrown")
    end

    def self.use_boost?
      self.get("loot.boost")
    end

    self.init!
  end
end