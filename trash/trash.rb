module Shiva
  module Trash
    @db = File.read(
      File.join(__dir__, "trash.db")).split("\n")

    def self.reload
      @db = File.read(
        File.join(__dir__, "trash.db")).split("\n")
    end

    def self.cursed?(item)
      return true if item.name =~ /oblivion quartz/ && Char.level < 100
      return false if item.name =~ /oblivion quartz/
      return item.type.include?("cursed")
    end

    def self.include?(item)
      @db.include?(item.name) or
      item.noun.eql?("truffle") or
      item.id.start_with?("-") or 
      item.type.include?("junk") or
      item.type.include?("food") or
      item.type.include?("herb") or
      item.name.end_with?("spear head") or
      item.name.end_with?("sticky web") or
      %w(wagon sign mandrake bandana kitten puppy disk signpost bramble vine).include?(item.noun) or
      self.cursed?(item)
    end
  end
end