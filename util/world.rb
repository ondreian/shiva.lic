module World
  Towns   = Map.list.select {|r| r.tags.include? "town" }
  @_cache = {}

  def self.by_town(tag)
    $teleport_disabled = true
    result = Hash[Towns.map {|town| [town.location, Room[town.find_nearest_by_tag(tag)]] }]
    $teleport_disabled = false
    result
  end

  def self.tag_for_town(town, tag)
    self.by_town(tag).find {|k,v| k.downcase.include?(town.downcase) }.last
  end
  
  def self.advguilds_by_town()
     self.by_town "advguild"
  end

  def self.gemshops_by_town()
    self.by_town "gemshop"
  end

  def self.furriers_by_town()
    self.by_town "furrier"
  end
end