# The <a exist="430652426" noun="dirk">dirk</a> strikes true, but <pushBold/>the <a exist="430840899" noun="siphon">soul siphon</a><popBold/> shrugs off some of the damage!

module Shiva
  class SymbolOfBless < Action
    HookName    = ":symbol-of-bless"
    NeedsBless  = %r[The <a exist="(\d+)" noun="\w+">\w+<\/a> strikes true]
    @@weapon_id = nil
    
    def self.register()
      DownstreamHook.add(HookName, -> str {
        SymbolOfBless.parse(str)
        str
      })
    
      before_dying do DownstreamHook.remove(HookName) end
    end

    def self.parse(str)
      return if @@weapon_id.is_a?(String)
      if result = str.match(NeedsBless)
        @@weapon_id = $1
      end
    end

    def self.id
      @@weapon_id
    end
  
    def self.needed?
      @@weapon_id.is_a?(String)
    end

    def self.reset!
      @@weapon_id = nil
    end

    def priority
      2
    end

    def available?
      SymbolOfBless.needed?
    end

    def apply
      waitrt?
      fput "symbol of bless #%s" % SymbolOfBless.id
      SymbolOfBless.reset!
    end
  end

  SymbolOfBless.register()
end