# -*- coding: utf-8 -*-
require "pry"

def generate_route(m)
  places = m.map{ |_distance, route| route }.flatten.sort.uniq
  currently_at = places.shuffle[0]
  visited = [currently_at]
  remaining_places = places - [currently_at]
  distance_traveled = 0

  count = 0
  while remaining_places.length >= 1 && count < 10 && distance_traveled < 155 do
    count += 1
    # puts "#{distance_traveled} @ #{currently_at} ... #{remaining_places}"
    distance, (pointA, pointB) = next_route = m.shuffle.find{ |distance, (pointA, pointB)|
      (pointA == currently_at and !visited.include?(pointB)) or
      (pointB == currently_at and !visited.include?(pointA))
    }
    return nil unless next_route
    m.delete next_route
    currently_at = pointA == currently_at ? pointB : pointA
    # puts "\t #{distance} → #{currently_at}"
    visited.push currently_at
    distance_traveled += distance.to_i
    remaining_places -= [currently_at]
  end

  if visited.sort == places
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
