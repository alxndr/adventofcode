def newcount(str)
  str.length + 2 + str.scan(/"/).count + str.scan(%r{\\}).count
end

IO.readlines("./08.txt").map{|s| ss = s.strip; {chars: ss.size, size: (eval ss).length, quoted: newcount(ss) }  }.reduce({chars: 0, size: 0, quoted: 0}) { |acc, elem| {chars: acc[:chars] + elem[:chars], size: acc[:size] + elem[:size], quoted: acc[:quoted] + elem[:quoted] } }
