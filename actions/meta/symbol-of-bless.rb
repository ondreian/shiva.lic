# The <a exist="430652426" noun="dirk">dirk</a> strikes true, but <pushBold/>the <a exist="430840899" noun="siphon">soul siphon</a><popBold/> shrugs off some of the damage!

module Shiva
  class SymbolOfBless < Action
    HookName    = "shiva/symbol-of-bless"
    NeedsBless  = Regexp.union(
      %r[The <a exist="(\d+)" noun="\w+">\w+<\/a> strikes true],
      %r[The <a exist="(\d+)" noun="\w+">\w+<\/a> strike true])
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
      @@weapon_id.to_s
    end

    def self.owned?
      Char.right.id.to_s.eql?(self.id) or 
      Char.left.id.to_s.eql?(self.id) or
      GameObj.inv.map(&:id).map(&:to_s).include?(self.id)
    end
  
    def self.needed?
      self.id and self.owned?
    end

    def self.reset!
      @@weapon_id = nil
    end

    def priority
      Priority.get(:high)
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