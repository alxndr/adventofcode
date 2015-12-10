# -*- coding: utf-8 -*-
require "pry"

def generate_route(the_map)
  places = the_map.map{ |_distance, route| route }.flatten.sort.uniq
  currently_at = places.shuffle[0]
  visited = [currently_at]
  remaining_places = places - [currently_at]
  distance_traveled = 0

  count = 0
  while distance_traveled < 155 && remaining_places.length > 0 && count < 25 do
    # keep track of iterations...
    count += 1

    # pick a route which includes wherever we currently are
    distance, (pointA, pointB) = next_route = the_map.shuffle.find{ |distance, (pointA, pointB)| pointA == currently_at || pointB == currently_at}

    # identify where we're going
    currently_at = pointA == currently_at ? pointB : pointA

    # go there
    visited.push currently_at

    # count how far it was
    distance_traveled += distance.to_i

    # note that we don't need to go there still
    remaining_places -= [currently_at]
  end

  if places.all?{ |place| visited.include? place }
    return distance_traveled, visited
  end
end

lines = IO.readlines("09.txt").map(&:strip)
mapp = lines.
  reduce({}) { |acc, elem|
    where, howfar = elem.split(" = ")
    acc[howfar] = where
    acc
  }.
  sort.
  map{ |distance, route| [distance, route.split(" to ").sort] }

shortest_distance = mapp.reduce(0) { |acc, (distance, _)| acc + distance.to_i }
shortest_route = nil

begin
  distance, route = generate_route(mapp.clone)
  next unless distance && route
  # puts distance, route.inspect
  if distance < shortest_distance
    shortest_distance = distance
    shortest_route = route
    puts "#{distance}: #{route.inspect}"
  end
end while true
