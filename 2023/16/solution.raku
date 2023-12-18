use v6;

my @mirror-field; # gonna be a 2d array...

my $file = open 'sample.txt';
for $file.lines -> $line {
  next unless $line;
  @mirror-field.push: $line.split('', :skip-empty);
}
say @mirror-field.join: "\n";
say "\n\n";

# mirror-field height & width:
my $w = @mirror-field[0].elems;
my $h = @mirror-field.elems;

my @light-travel-path[$w;$h]; # tracks where the photons have been

sub print-light-path() {
  loop (my $y = 0; $y < $h; $y++) {
    say [ -> \x { @light-travel-path[x;$y] ?? "#" !! " " } for [0 ..^ $w] ].join: ""
  }
}

enum Dir <N S E W>;

class Photon {
  has Int $.x;
  has Int $.y;
  has Dir $.dir;
  method to_s { return "P\{{$.dir}\} @ {$.x}/{$.y} ({@mirror-field[$.x][$.y]})" }
}

sub get-next-shape (Photon $p) {
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
  say $photon.to_s;
  @light-travel-path[$photon.x;$photon.y] ||= [];
  @light-travel-path[$photon.x;$photon.y].push($photon.dir); # track where it's been...
  my @next-photons = get-next-photons $photon; # determine where its next position will be...
  for @next-photons -> $potential-photon { # for each of these, look in light-travel-path
    next unless $potential-photon;
    if ($potential-photon.dir ∈ @light-travel-path[$potential-photon.x;$potential-photon.y]) { # ...if the next x/y has had that dir before, don't push it into @photons
      # say "\t... nope, {$potential-photon.to_s} already seen";
    } else { # ...but if not, push it in and we'll continue iterating
      @photons.push: $potential-photon;
    }
  }
  print-light-path
}

say "ok that's all";

print-light-path;

my $primitive-addition = 0;
loop (my $y = 0; $y < $h; $y++) {
  loop (my $x = 0; $x < $w; $x++) {
    if (@light-travel-path[$x;$y]) {
      $primitive-addition++;
    }
  }
}
say $primitive-addition
