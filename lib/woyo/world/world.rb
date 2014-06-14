require_relative 'world_object'
require_relative 'location'
require_relative 'way'
require_relative 'character'

module Woyo

class World < WorldObject

  children :location, :character

  def initialize_object
    super
    attributes :name, :description, :start
  end

  def initialize &block
    super nil, context: nil, &block
  end

end

end