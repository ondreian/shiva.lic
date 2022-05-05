module World
  Towns   = Map.list.select {|r| r.tags.include? "town" }
  @_cache = {}

  def self.by_town(tag)
    @_cache[tag] ||= Hash[Map.list.select {|r| r.tags.include? tag }.map {|r| 
      [Room[r.find_nearest_by_tag("town")].location, r]
    }]
  end
  
  def self.advguilds_by_town()
     self.by_town "advguild"
  end

  def self.gemshops_by_town()
    self.by_town "gemshop"
  end
end