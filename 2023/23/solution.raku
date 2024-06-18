#!/usr/bin/env raku

use Test;

sub input-sample () { [.split('', :skip-empty) for open('sample.txt').lines] }
sub input-full ()   { [.split('', :skip-empty) for open( 'input.txt').lines] }

sub neighbors-of (@yxm, @map) {
  # say @yxm;
  my @neighbor-list = [];
  my $y = Int(@yxm[0]);
  my $x = Int(@yxm[1]);
  my $above = $y - 1;
  my $below = $y + 1;
  my $left  = $x - 1;
  my $right = $x + 1;
  # say "\ny $y x $x ... above $above ; left $left ; below $below ; right $right ...";
  my $map-height = @map.elems;
  my $map-width  = @map[0].elems;
  @neighbor-list.push([$above, $x, '^']) if ($above >= 0);
  @neighbor-list.push([$y,  $left, '<']) if ($left  >= 0);
  @neighbor-list.push([$y, $right, '>']) if ($right <= $map-width);
  @neighbor-list.push([$below, $x, 'v']) if ($below <= $map-height);
  @neighbor-list
}

sub is-viable-move (@yxm, @map) {
  say "is-viable-move ... ", @yxm;
  my $tile = @map[@yxm[0]][@yxm[1]];
  say "viable?? ", @yxm, " -> ", $tile;
  return True  if ($tile eq '.');
  return False if ($tile eq '#');
  my $entering-move = @yxm[2];
  say "viable to enter ?? $entering-move eq $tile ???? ...";
  return ($entering-move eq $tile);
}

sub format-route($route, @map) {
  my @result = [];
  loop (my $y = 0; $y < @map.elems; $y++) {
    my @line = [];
    loop (my $x = 0; $x < @map[0].elems; $x++) {
      say "route... {$route} ... [$y, $x]";
      # say "route[0] {@route[0]} route[1] {@route[1]}";
      if (($y, $x) ∈ $route) {
        @line.push("X");
      } else {
        @line.push(@map[$y][$x]);
      }
    }
    @result.push(@line.join(''));
  }
  @result
}

sub do-the-thing(@routes, @map) {
  for @routes <-> @route {
    say "\n...route... ", @route;
    say format-route(@route, @map).join("\n");
    my @head = @route.head;
    say "head {@head} after {@route.elems} steps";
    # prompt;
    # my @neighbors = neighbors-of(@head, @map);
    # say "neighbors... ", @neighbors;
    # my @next-moves = [$_ if is-viable-move($_, @map) for @neighbors];
    # say "next moves? ", @next-moves;
    # for @next-moves -> @next-move {
    #   say "next move??? >>>> ", @next-move;
    #   if ([@next-move[0], @next-move[1]] ∈ @route) {
    #     say "skip it, already been to ({@next-move[0]}-{@next-move[1]})";
    #     next;
    #   }
    #   prompt;
    #   @routes.push(@route.push(@next-move));
    # }
  }
}

# class Move {
#   # x, y, dir
# }

sub part1 (@input) {
  my @route = [
    (0, 0,),
    (0, 1,),
  ];
  do-the-thing([@route,], @input)
}

say "\n\n\n\n=============\n";


say input-sample;

plan 1;
ok part1(input-sample) === 94;
