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

puts (0..9999).
  map { generate_route(mapp.clone) }.
  compact.
  sort{ |(dA, _r), (dB, _r)| dA.<=>(dB) }.
  map{ |distance, route| "#{distance}: #{route.inspect}" }.
  join("\n")

# 155: ["Arbre", "Norrath", "Straylight", "Faerun", "Snowdin", "Tambi", "AlphaCentauri", "Tristram"]
# 155: ["Arbre", "Norrath", "Straylight", "Faerun", "Snowdin", "Tambi", "AlphaCentauri", "Tristram"]
# 157: ["Arbre", "Tambi", "Snowdin", "Faerun", "Straylight", "Norrath", "Tristram", "AlphaCentauri"]
# 177: ["Norrath", "Straylight", "AlphaCentauri", "Tristram", "Faerun", "Snowdin", "Tambi", "Arbre"]
# 162: ["AlphaCentauri", "Tristram", "Tambi", "Snowdin", "Faerun", "Straylight", "Norrath", "Arbre"]
# 173: ["Faerun", "Snowdin", "Tambi", "Arbre", "Norrath", "Straylight", "Tristram", "AlphaCentauri"]
# 185: ["Arbre", "Tristram", "AlphaCentauri", "Tambi", "Snowdin", "Faerun", "Straylight", "Norrath"]
# 185: ["AlphaCentauri", "Tristram", "Straylight", "Faerun", "Snowdin", "Tambi", "Arbre", "Norrath"]
