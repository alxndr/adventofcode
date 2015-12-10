# -*- coding: utf-8 -*-
require "pry"

def generate_route(the_map)
  places = the_map.map{ |_distance, route| route }.flatten.sort.uniq
  currently_at = places.shuffle[0]
  visited = [currently_at]
  remaining_places = places - [currently_at]
  distance_traveled = 0

  count = 0
  while remaining_places.length > 0 && count < 10 do
    # keep track of iterations...
    count += 1

    # pick a route which includes wherever we currently are, and a destination we haven't visited
    distance, (pointA, pointB) = the_map.shuffle.find{ |_distance, (pointA, pointB)|
      (pointA == currently_at && remaining_places.include?(pointB)) ||
      (pointB == currently_at && remaining_places.include?(pointA))
    }

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
mapp = lines
  .map { |route|
    where, howfar = route.split(" = ")
    pointA, pointB = where.split(" to ")
    [howfar, [pointA, pointB]]
  }
  .sort

longest_distance = 0
longest_route = nil

begin
  distance, route = generate_route(mapp.clone)
  next unless distance && route
  # puts distance, route.inspect
  if distance > longest_distance
    longest_distance = distance
    longest_route = route
    puts "#{distance}: #{route.inspect}"
  end
end while true
