module Santa
  X = 0
  Y = 1

  def self.find_path(directions_string)
    santa_position = [0, 0]
    robot_position = [0, 0]
    last_move = nil
    directions_string.chars.reduce({pos_key([0, 0]) => 2}) do |path_info, dir|
      if last_move == :santa
        last_move = :robot
        position = robot_position
      else
        last_move = :santa
        position = santa_position
      end
      record_move dir, position
      position_string = pos_key(position)
      if path_info[position_string]
        path_info[position_string] += 1
      else
        path_info[position_string] = 1
      end
      puts "Santa: #{pos_key(santa_position)} (#{path_info[pos_key(santa_position)]})\tRobot: #{pos_key(robot_position)} (#{path_info[pos_key(robot_position)]})"
      path_info
    end
  end

  def self.houses_with_presents(directions_string)
    find_path(directions_string).length
  end

  def self.houses_with_lots_of_presents(directions_string)
    find_path(directions_string)
      .find_all{ |(_house_coords, num_presents)| num_presents > 1 }
      .count
  end

  private

  def self.record_move(dir, position)
    case dir
    when "^"
      position[Y] += 1
    when "<"
      position[X] -= 1
    when ">"
      position[X] += 1
    when "v"
      position[Y] -= 1
    else
      puts "unrecognized character! unacceptable! #{dir}"
    end
  end

  def self.pos_key(position)
    "#{position[X]}x#{position[Y]}"
  end

end

