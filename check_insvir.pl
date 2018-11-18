#!/usr/bin/perl -w

use strict;

# check_insvir.pl (normal integration output) (insvir integration output) (primer info)

my $file1 = shift;
my $file2 = shift;
my $refs  = shift;

my $margin = 3;

###
### Read reference seq. of terminals at viral genomes
###
my $ref3F;
my $ref5F;
my $lref3F;
my $lref5F;
my $p3F;
my $p5F;
open REFS, "$refs";
while(<REFS>){
  s/\A\s+//;
  s/\s+\Z//;
  my $line = $_;

  if(/\A3FE\s+(\w+)\Z/){
    $ref3F  = $1;
    $lref3F = length($ref3F);
  }elsif(/\A5FE\s+(\w+)\Z/){
    $ref5F  = $1;
    $lref5F = length($ref5F);
  }
  elsif(/\A3F\s+(\w+)\Z/){
    $p3F  = $1;
  }elsif(/\A5F\s+(\w+)\Z/){
    $p5F  = $1;
  }
}
close REFS;

my $data;

open FILE1, "$file1";
while(<FILE1>){
  s/\A\s+//;
  s/\s+\Z//;
  my $line = $_;

  if(/\A(chr\S+),\s+(\d+)\,/){
    my $c = $1;
    my $d = $2;
    $data->{$c}->{$d} = 1;
  }
}
close FILE1;

my $flag = 0;
open FILE2, "$file2";
while(<FILE2>){
  my $line = $_;
  s/\A\s+//;
  s/\s+\Z//;

  if(/\Achr\S+,\s+\D+\,/){
    printf "%s", $line;
    $flag = 0;
  }
  if(/\A(chr\S+),\s+(\d+)\,/){
    my $c = $1;
    my $d = $2;
    my $line2 = $line;
       $line2 =~ s/\,//g;
    my @s     = split /\s+/, $line2;

    my $pri = $s[2];
    my $str = $s[3];
    my $l   = $s[8];

    if($str eq "+" && $pri eq "5'"){ $d = $d - ($l - $lref5F); }
    if($str eq "+" && $pri eq "3'"){ $d = $d - ($l - $lref3F); }
    if($str eq "-" && $pri eq "5'"){ $d = $d + ($l - $lref5F); }
    if($str eq "-" && $pri eq "3'"){ $d = $d + ($l - $lref3F); }
    
    my $f = 0;
    foreach my $i (sort {$main::a <=> $main::b} keys %{$data->{$c}}){
      if(abs($i - $d) <= $margin){ $f++; }
    }

    if($f == 0){ 
      printf "%s", $line; 
      $flag = 0;
    }
  }
  if(/\A\Z/){
    if($flag == 0){ printf "%s", $line; }
    $flag++;
  }
}
close FILE2;

