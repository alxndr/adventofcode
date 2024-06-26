#!/usr/bin/env raku

use Test;

say "\n\n===========================\n\n\n";

sub input-sample () { [.split(/\s+/, :skip-empty) for open('sample.txt').lines] }
sub input-full ()   { [.split(/\s+/, :skip-empty) for open( 'input.txt').lines] }

sub build-vertices(@input) {
  my @vertices = [ (0,0), ];
  # say @vertices;
  gather for @input {
    my $dir = $_[0];
    my $dist = $_[1];
    # say "dir:", $dir, " x ", $dist;
    my $lastX = @vertices[*-1][0];
    my $lastY = @vertices[*-1][1];
    # say "@($lastX,$lastY)... ";
    my $nextX = $lastX;
    my $nextY = $lastY;
    given $dir {
      when 'R' {
        $nextX += $dist;
      }
      when 'D' {
        $nextY -= $dist;
      }
      when 'L' {
        $nextX -= $dist;
      }
      when 'U' {
        $nextY += $dist;
      }
    }
    @vertices.push: ($nextX, $nextY)
  };
  @vertices;
}

sub trapezoid-algo(@vs) {
  # assumes "positively oriented (counter clock wise) sequence of points"
  # https://en.wikipedia.org/wiki/Shoelace_formula#Trapezoid_formula
  reduce(-> Rat $area, List $l {
    my $a = $l[0]; my $aX = $a[0]; my $aY = $a[1];
    my $b = $l[1]; my $bX = $b[0]; my $bY = $b[1];
    my $result = $area + 0.5 * ($aY + $bY) * ($aX - $bX);
    say "reducing ($area) + 0.5 * ($aY + $bY) * ($aX - $bX) ... = $result !";
    $result
  }, 0.0, |@vs.rotor(2 => -1)).abs;
}

sub part1 (@input) {
  say "\npart 1...\n";
  my @vertices = build-vertices(@input);
  say @vertices, "\n";
  say "max of first coordinate";
  say @vertices.map(-> $v { $v[0] }).map(*.Numeric).max;
  say "min of first coordinate";
  say @vertices.map(-> $v { $v[0] }).map(*.Numeric).min;
  say "max of second coordinate";
  say @vertices.map(-> $v { $v[1] }).map(*.Numeric).max;
  say "min of second coordinate";
  say @vertices.map(-> $v { $v[1] }).map(*.Numeric).min;
  # trapezoid-algo(@vertices);
}

plan 1;
ok part1(input-full) === 62;
