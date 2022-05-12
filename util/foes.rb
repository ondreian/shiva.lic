module Shiva
  class Foes
    SPECIALS = %i[champion automaton slaver hunter yeti troll mammoth]
    BONELESS = %w[caedera crawler roa'ter kiramon crab worm beetle]

    def self.add_tags(creature)
      SPECIALS.each do |type|
        creature.tags << type if creature.name.include?(type.to_s)
      end
      creature.tags.push(:boneless) if BONELESS.include?(creature.noun)
      creature
    end

    include Enumerable

    def each()
      return [] unless Claim.mine?
      GameObj.targets.to_a
        .reject do |candidate| candidate.name =~ /animated|arm$/ end
        .map  do |obj| Creature.new(obj) end
        .reject do |foe| foe.level < (Char.level - 10) end
        .map  do |creature| Foes.add_tags(creature) end
        .sort_by(&:level)
        .each do |creature| yield(creature) if GameObj[creature.id] end
    end

    def self.prone
      find do |c| c.status.include?(:prone) end
    end

    def self.stunned
      find do |c| c.status.include?(:stunned) end
    end

    def self.dead()
      GameObj.npcs.to_a.select do |npc| npc.status.include?("dead") end
    end

    def self.is?(type)
      first.tags.include?(type)
    end

    def self.slaver?
      is? :slaver
    end

    def self.champion?
      is?(:champion) or is?(:automaton)
    end

    def self.statuses
      new.map(&:status).flatten
    end

    def self.first
      if Group.members.size < 3
        new.first
      elsif statuses.empty?
        new.sample
      elsif any? do |c| c.status.empty? end
        find do |c| c.status.empty? end
      else
        new.sample
      end
    end

    def respond_to_missing?(method, include_private = false)
      to_a.respond_to?(method) or super
    end

    def method_missing(method, *args)
      if to_a.respond_to?(method)
        to_a.send(method, *args)
      else
        super(method, *args)
      end
    end

    def self.method_missing(method, *args, &block)
      if respond_to?(method)
        Foes.new.send(method, *args, &block)
      else
        super
      end
    end

    def self.respond_to?(method)
      return super(method) unless Foes.new.respond_to?(method)
      return true
    end
  end
end 