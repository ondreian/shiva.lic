module Shiva
  module Trash
    @db = File.read(
      File.join(__dir__, "trash.db")).split("\n")

    def self.reload
      @db = File.read(
        File.join(__dir__, "trash.db")).split("\n")
    end

    def self.include?(item)
      @db.include?(item.name)
    end
  end
end