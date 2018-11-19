#!/usr/bin/perl -w

use strict;

my $file = shift;
my $refs = shift;
my $out  = shift;

my $margin = 3;

open OUT, ">$out";

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

open FILE, "$file";
while(<FILE>){
  my $line = $_;

  my $s = $line;
     $s =~ s/\,//g;
  my @s = split /\s+/, $s;
  if($s[1] =~ /\d+/){
#chr1, 1862332,     5',     +,     1862472,     140,    0,    1, 48_56,  CTTGTCTTTTCTGTGAGTAAATTAGCCCTTCCAGTCCCCCCTTTTCTT_TTAAAAAG
    my $chr = $s[0];
    my $pos = $s[1];
    my $pri = $s[2];
    my $str = $s[3];
    my $bre = $s[4];
    my $dis = $s[5];
    my $c1  = $s[6];
    my $c2  = $s[7];
    my $dis2= $s[8];
    my $seq = $s[9];

    my @d   = split /\_/, $dis2;
    my @seq = split /\_/, $seq;

    if(($d[1] - $d[0]) >= (-1 * $margin)){ 
      printf OUT "%s,	%d,	%s,	%s,	%d,	%d,	%d,	%d,	%d,", $chr, $pos, $pri, $str, $bre, $dis, $c1, $c2, $d[0];
      if($d[0] <= $d[1]){ printf OUT "	%s,", $seq[0]; }
      else{               printf OUT "	%s,", $seq[0] . $seq[1]; }

      if($pri eq "3'"){
        if($lref3F < $d[0]){ printf OUT "	INS\n"; }
        else{                printf OUT "	DEL\n"; }
      }
      if($pri eq "5'"){
        if($lref5F < $d[0]){ printf OUT "	INS\n"; }
        else{                printf OUT "	DEL\n"; }
      }
    }
    else{
      printf STDOUT "%s", $line;
    }
  }
  else{
    printf OUT "%s", $line;
    printf STDOUT "%s", $line;
  }

}
close FILE;

