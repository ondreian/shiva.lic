module Injuries
  @wounds = Wounds.singleton_methods
      .map(&:to_s)
      .select do |m| m.downcase == m && m !~ /_/ end.map(&:to_sym)
  @scars = Scars.singleton_methods
      .map(&:to_s)
      .select do |m| m.downcase == m && m !~ /_/ end.map(&:to_sym)

  def self.wounds()
    @wounds.map {|m| Wounds.send(m)}
  end

  def self.scars()
    @scars.map {|m| Scars.send(m)}
  end
end