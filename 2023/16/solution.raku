use v6;

my @mirror-field; # poor-coders 2d array... 1st dim is Y, 2nd dim is X (backwards from the @light-travel-path true 2d array)

# my $file = open 'sample.txt';
my $file = open 'input.txt';
for $file.lines -> $line {
  @mirror-field.push: $line.split('', :skip-empty) if $line;
}
say @mirror-field;

my $w = @mirror-field[0].elems;
my $h = @mirror-field.elems;

my @light-travel-path[$w;$h]; # tracks where the photons have been

sub print-light-path() {
  loop (my $y = 0; $y < $h; $y++) {
    say [ -> \x {
      @light-travel-path[x;$y] ?? "#" !! @mirror-field[$y][x]
    } for [0 ..^ $w] ].join: ""
  }
}

sub add-em-up() {
  my $primitive-addition = 0;
  loop (my $y = 0; $y < $h; $y++) {
    loop (my $x = 0; $x < $w; $x++) {
      if (@light-travel-path[$x;$y]) {
        $primitive-addition++;
      }
    }
  }
  return $primitive-addition; # 7440 is too low...
}

enum Dir <N S E W>;

class Photon {
  has Int $.x;
  has Int $.y;
  has Dir $.dir;
  method to_s { return "Photon\{{$.dir}\} @ {$.x}/{$.y} ({@mirror-field[$.y][$.x]})" }
}

sub get-next-shape (Photon $p) {
  # say "get-next-shape... ", $p.to_s;
  given $p.dir {
    when N { return $p.y >=  1 ?? @mirror-field[$p.y-1][$p.x  ] !! Nil }
    when E { return $p.x <= $w ?? @mirror-field[$p.y  ][$p.x+1] !! Nil }
    when S { return $p.y <= $h ?? @mirror-field[$p.y+1][$p.x  ] !! Nil }
    when W { return $p.x >=  1 ?? @mirror-field[$p.y  ][$p.x-1] !! Nil }
    default { die "where are we goin {$p.dir}" }
  }
}

sub get-next-photons (Photon $p) {
  my $next-shape = get-next-shape $p;
  return (Nil) unless $next-shape;
  # say $p.to_s;
  # say "\tnext-shape: >{$next-shape}<";
  given $next-shape {
    when '.' {
      given $p.dir {
        when N { return (Photon.new(x=>$p.x  , y=>$p.y-1, dir=>$p.dir)) }
        when W { return (Photon.new(x=>$p.x-1, y=>$p.y  , dir=>$p.dir)) }
        when S { return (Photon.new(x=>$p.x  , y=>$p.y+1, dir=>$p.dir)) }
        when E { return (Photon.new(x=>$p.x+1, y=>$p.y  , dir=>$p.dir)) }
        default { die "what direction?? {$p.dir}" }
      }
    }
    when '|' {
      given $p.dir {
        when N { return (Photon.new(x=>$p.x  , y=>$p.y-1, dir=>N)) }
        when W { return (Photon.new(x=>$p.x-1, y=>$p.y  , dir=>N),
                         Photon.new(x=>$p.x-1, y=>$p.y  , dir=>S)) }
        when S { return (Photon.new(x=>$p.x  , y=>$p.y+1, dir=>S)) }
        when E { return (Photon.new(x=>$p.x+1, y=>$p.y  , dir=>N),
                         Photon.new(x=>$p.x+1, y=>$p.y  , dir=>S)) }
        default { die "what direction?? {$p.dir}" }
      }
    }
    when '-' {
      given $p.dir {
        when N { return (Photon.new(x=>$p.x  , y=>$p.y-1, dir=>W),
                         Photon.new(x=>$p.x  , y=>$p.y-1, dir=>E)) }
        when W { return (Photon.new(x=>$p.x-1, y=>$p.y  , dir=>W)) }
        when S { return (Photon.new(x=>$p.x  , y=>$p.y+1, dir=>W),
                         Photon.new(x=>$p.x  , y=>$p.y+1, dir=>E)) }
        when E { return (Photon.new(x=>$p.x+1, y=>$p.y  , dir=>E)) }
        default { die "what direction?? {$p.dir}" }
      }
    }
    when '/' {
      given $p.dir {
        when N { return (Photon.new(x=>$p.x  , y=>$p.y-1, dir=>E)) }
        when W { return (Photon.new(x=>$p.x-1, y=>$p.y  , dir=>S)) }
        when S { return (Photon.new(x=>$p.x  , y=>$p.y+1, dir=>W)) }
        when E { return (Photon.new(x=>$p.x+1, y=>$p.y  , dir=>N)) }
        default { die "what direction?? {$p.dir}" }
      }
    }
    when '\\' {
      given $p.dir {
        when N { return (Photon.new(x=>$p.x  , y=>$p.y-1, dir=>W)) }
        when W { return (Photon.new(x=>$p.x-1, y=>$p.y  , dir=>N)) }
        when S { return (Photon.new(x=>$p.x  , y=>$p.y+1, dir=>E)) }
        when E { return (Photon.new(x=>$p.x+1, y=>$p.y  , dir=>S)) }
        default { die "what direction?? {$p.dir}" }
      }
    }
    default { die "ruh roh dunno what that shape is {$next-shape}" }
  }
}

my @photons;
@photons.push: Photon.new(x=>0, y=>0, dir=>E);

for @photons <-> $photon { # for each photon...
  @light-travel-path[$photon.x;$photon.y] ||= [];
  @light-travel-path[$photon.x;$photon.y].push($photon.dir); # track where it's been...
  my @next-photons = get-next-photons $photon; # determine where its next position will be...
  for @next-photons -> $potential-photon { # for each of these, look in light-travel-path
    next unless $potential-photon;
    # say "potential next photons!:", $potential-photon.to_s;
    if ($potential-photon.dir ∈ @light-travel-path[$potential-photon.x;$potential-photon.y]) { # ...if the next x/y has had that dir before, don't push it into @photons
      # say "\t... nope, {$potential-photon.to_s} already seen";
    } else { # ...but if not, push it in and we'll continue iterating
      @photons.push: $potential-photon;
    }
  }
  # my $sum = add-em-up;
  # if ($sum %% 131) {
  #   say "\n\n\n";
  #   print-light-path;
  #   say "\n\n\n", $sum, "\n\n";
  #   # prompt;
  # }
}

say "ok that's all";

print-light-path;

say add-em-up;
