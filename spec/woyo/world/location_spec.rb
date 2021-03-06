require 'spec_helper'
require 'woyo/world/world'
require 'woyo/world/location'
require 'woyo/world/item'
require 'woyo/world/way'

describe Woyo::Location do

  let(:location) { Woyo::Location.new :home }

  it 'accepts world for parameter context:' do
    wo = nil
    expect { wo = Woyo::Location.new(:my_id, context: Woyo::World.new) }.to_not raise_error
    expect(wo.context).to be_instance_of Woyo::World
  end

  it '#here' do
    home = Woyo::Location.new :home 
    expect(home.here).to be home
  end

  it '#world' do
    world = Woyo::World.new
    home = Woyo::Location.new :home, context: world
    expect(home.world).to eq world
  end

  context 'ways' do

    it 'are listed (#ways)' do
      home = Woyo::Location.new :home do
        way( :up   ) { to :roof   }
        way( :down ) { to :cellar }
        way( :out  ) { to :garden }
      end
      expect(home.ways.count).to eq 3
      expect(home.ways.keys).to eq [ :up, :down, :out ]
    end

    it 'are from here' do
      home = Woyo::Location.new :home do
        way :door do
          to :away
        end
      end
      door = home.ways[:door]
      expect(door.from).to eq home
    end

    it 'go to locations' do
      home = Woyo::Location.new :home do
        way :door do
          to :away
        end
      end
      door = home.ways[:door]
      expect(door.to).to be_instance_of Woyo::Location
      expect(door.to.id).to eq :away
    end

  end

  context 'items' do

    let( :home ) do
      home = Woyo::Location.new :home do
        item( :thing1 ) { description 'Thing One' }
        item( :thing2 ) { description 'Thing two' }
      end
    end

    it 'are listed' do
      expect(home.items.count).to eq 2
      expect(home.items.keys).to eq [ :thing1, :thing2 ]
    end

    it 'are accessible' do
      expect(thing = home.items[:thing1]).to be_instance_of Woyo::Item
      expect(thing.id).to eq :thing1
      expect(thing.description).to eq 'Thing One'
    end

  end

  context 'actions' do

    it 'execute returns changes for location' do
      home = Woyo::Location.new :home do
        item :thing do
          action :make_changes do
            execution do |action|
              name 'Changed item'
              action.name 'Changed action'
              location.name 'Changed location'
            end
          end
        end
      end
      expect(home.item(:thing).action(:make_changes).execute[:changes]).to eq( {
        name: "Changed location",
        item: {
          thing: {
            name: "Changed item",
            action: {
              make_changes: {
                name: "Changed action"
              }
            }
          }
        }
      })
    end

    it 'execute returns changes for location for this execution only' do
      home = Woyo::Location.new :home do
        item :thing do
          action :make_changes do
            attribute count: 0
            execution do |action|
              action.count += 1
              name "Changed item #{action.count}"
              action.name "Changed action #{action.count}"
              location.name "Changed location #{action.count}"
            end
          end
          action :more_changes do
            execution do |action|
              name "Changed item more"
              action.name "Changed action more"
              location.name "Changed location more"
            end
          end
        end
      end
      expect(home.item(:thing).action(:make_changes).execute[:changes]).to eq( {
        name: "Changed location 1", item: { thing: { name: "Changed item 1", action: { make_changes: { count: 1, name: "Changed action 1" } } } }
      })
      expect(home.item(:thing).action(:make_changes).execute[:changes]).to eq( {
        name: "Changed location 2", item: { thing: { name: "Changed item 2", action: { make_changes: { count: 2, name: "Changed action 2" } } } }
      })
      expect(home.item(:thing).action(:more_changes).execute[:changes]).to eq( {
        name: "Changed location more", item: { thing: { name: "Changed item more", action: { more_changes: { name: "Changed action more" } } } }
      })
    end
  end

end
