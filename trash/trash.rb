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
      return true if item.name =~ /quartz orb$/
      return item.type.include?("cursed")
    end

    def self.include?(item)
      @db.include?(item.name) or
      item.noun.eql?("truffle") or
      item.id.start_with?("-") or 
      item.type.include?("junk") or
      item.type.include?("food") or
      item.type.include?("herb") or
      item.noun.eql?("golem") or
      item.name.eql?("basket of sticks") or
      item.name.end_with?("spear head") or
      item.name.end_with?("sticky web") or
      item.name.eql?("spiraling ghostly rift") or
      item.name.include?("flying ") or
      item.name.eql?("violently lashing emerald briar") or
      %w(wagon sign mandrake bandana kitten puppy disk tempest signpost bramble vine).include?(item.noun) or
      self.cursed?(item)
    end
  end
end