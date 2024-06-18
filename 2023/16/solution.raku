#!/usr/bin/env raku

use v6;

my $corpus = @*ARGS[0] || 'input';

my @mirror-field; # fake 2d array...
for open("{$corpus}.txt").lines -> $line {
  @mirror-field.push: $line.split('', :skip-empty) if $line;
}

my $w = @mirror-field[0].elems;
my $h = @mirror-field.elems;

my @paths[$h;$w]; # tracks where the photons have been

sub format-light-path() {
  [ -> $y
    {
      [ -> $x
        {
          @paths[$y;$x] ?? @paths[$y;$x].elems !! @mirror-field[$y][$x]
        } for [0 ..^ $w]
      ].join: ""
    } for [0 ..^ $h]
  ].join: "\n"
}

sub add-em-up() {
  my $primitive-addition = 0;
  loop (my $y = 0; $y < $h; $y++) {
    loop (my $x = 0; $x < $w; $x++) {
      if (@paths[$y;$x]) {
        $primitive-addition++;
      }
    }
  }
  return $primitive-addition;
}

enum Dir <N S E W>;

class Photon {
  has Int $.x;
  has Int $.y;
  has Dir $.dir;
  method WHICH { ValueObjAt.new: "Photon|\{{$.dir} @ {$.x}/{$.y}\}" }
  method opposite-dir {
    given $.dir {
      when N { S }
      when S { N }
      when E { W }
      when W { E }
    }
  }
}

sub get-next-shape (Photon $p) {
  given $p.dir {
    when N { return $p.y >=  1 ?? @mirror-field[$p.y-1][$p.x  ] !! Nil; }
    when E { return $p.x <= $w ?? @mirror-field[$p.y  ][$p.x+1] !! Nil; }
    when S { return $p.y <= $h ?? @mirror-field[$p.y+1][$p.x  ] !! Nil; }
    when W { return $p.x >=  1 ?? @mirror-field[$p.y  ][$p.x-1] !! Nil; }
    default { die "where are we goin {$p.dir}"; }
  }
}

sub get-next-photons (Photon $p) {
  my $next-shape = get-next-shape $p;
  given $next-shape {
    when '.' {
      given $p.dir {
        when N { return (Photon.new(x=>$p.x  , y=>$p.y-1, dir=>$p.dir)); }
        when W { return (Photon.new(x=>$p.x-1, y=>$p.y  , dir=>$p.dir)); }
        when S { return (Photon.new(x=>$p.x  , y=>$p.y+1, dir=>$p.dir)); }
        when E { return (Photon.new(x=>$p.x+1, y=>$p.y  , dir=>$p.dir)); }
        default { die "what direction?? (.) {$p.dir}"; }
      }
    }
    when '|' {
      given $p.dir {
        when N { return (Photon.new(x=>$p.x  , y=>$p.y-1, dir=>N)); }
        when W { return (Photon.new(x=>$p.x-1, y=>$p.y  , dir=>N),
                         Photon.new(x=>$p.x-1, y=>$p.y  , dir=>S)); }
        when S { return (Photon.new(x=>$p.x  , y=>$p.y+1, dir=>S)); }
        when E { return (Photon.new(x=>$p.x+1, y=>$p.y  , dir=>N),
                         Photon.new(x=>$p.x+1, y=>$p.y  , dir=>S)); }
        default { die "what direction?? (|) {$p.dir}"; }
      }
    }
    when '-' {
      given $p.dir {
        when N { return (Photon.new(x=>$p.x  , y=>$p.y-1, dir=>W),
                         Photon.new(x=>$p.x  , y=>$p.y-1, dir=>E)); }
        when W { return (Photon.new(x=>$p.x-1, y=>$p.y  , dir=>W)); }
        when S { return (Photon.new(x=>$p.x  , y=>$p.y+1, dir=>W),
                         Photon.new(x=>$p.x  , y=>$p.y+1, dir=>E)); }
        when E { return (Photon.new(x=>$p.x+1, y=>$p.y  , dir=>E)); }
        default { die "what direction?? (-) {$p.dir}"; }
      }
    }
    when '/' {
      given $p.dir {
        when N { return (Photon.new(x=>$p.x  , y=>$p.y-1, dir=>E)); }
        when W { return (Photon.new(x=>$p.x-1, y=>$p.y  , dir=>S)); }
        when S { return (Photon.new(x=>$p.x  , y=>$p.y+1, dir=>W)); }
        when E { return (Photon.new(x=>$p.x+1, y=>$p.y  , dir=>N)); }
        default { die "what direction?? (/) {$p.dir}"; }
      }
    }
    when '\\' {
      given $p.dir {
        when N { return (Photon.new(x=>$p.x  , y=>$p.y-1, dir=>W)); }
        when W { return (Photon.new(x=>$p.x-1, y=>$p.y  , dir=>N)); }
        when S { return (Photon.new(x=>$p.x  , y=>$p.y+1, dir=>E)); }
        when E { return (Photon.new(x=>$p.x+1, y=>$p.y  , dir=>S)); }
        default { die "what direction?? (\\) {$p.dir}"; }
      }
    }
    default { return (); }
  }
}

my @photons = [ Photon.new: :0x, :0y, dir=>E ];
my $photon;
my $photons-counter = 0;
while ($photon = @photons.pop) {
  $photons-counter++ if (!@paths[$photon.y;$photon.x]);
  @paths[$photon.y;$photon.x].push: $photon.dir;
  for get-next-photons($photon) -> $next-photon {
    my $record-of-prior-photons = @paths[$next-photon.y;$next-photon.x];
    @photons.push: $next-photon
      unless $next-photon ∈ @photons
        or $next-photon.dir ∈ $record-of-prior-photons
        # or (@photons.elems != 2 && $next-photon.opposite-dir ∈ $record-of-prior-photons) TODO could also skip if the direction is opposite current direction IFF we still keep the splitter behavior
  }
  # say "\n", format-light-path, "\n\t", [1 if $_ for @paths].sum;
  # prompt;
}

say format-light-path;
say "\ncounter...", $photons-counter, "\n"; # 16275 with twins... 10940 without!
say "\nfield is $w wide • $h high...\n";
say "\n... real-seeming-but-flawed count of lit tiles is: {add-em-up}\n";
say 'still-flawed sum using listcomp... ', [1 if $_ for @paths].sum, "\n";
# 7440 is too low
# 7450 is too low...
# 7774 is too high
