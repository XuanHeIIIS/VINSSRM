#!/usr/bin/perl -w

use strict;
my $file = shift;

my $pre    = 0;
my $pres   = "";
my $pred   = 0;
my $prec   = 0;
my $margin = 3;

open FILE, "$file";
while(<FILE>){
  my $line = $_;
  my $line2 = $line;
     $line2 =~ s/^\#//;
     $line2 =~ s/\,//g;
  my @s = split /\s+/, $line2;
  if($s[1] =~ /\d+/){
    if($#s > 9){
      my $r;
      if($s[10] =~ /^chr/){ $r = $s[10]; }
      else                { $r = "virus"; }

      if(abs($s[1] - $pre) <= $margin && $pres eq $s[2] && abs($s[8] - $pred) <= $margin && $prec eq $r){
        ;
      }else{
        print "\n";
      }
      printf $line;
      $pre  = $s[1];
      $pres = $s[2];
      $pred = $s[8];
      $prec = $r;
    }elsif($#s > 7){
      if(abs($s[1] - $pre) <= $margin && $pres eq $s[2] && abs($s[8] - $pred) <= $margin){
        ;
      }else{
        print "\n";
      }
      printf $line;
      $pre  = $s[1];
      $pres = $s[2];
      $pred = $s[8];
    }else{
      if(abs($s[1] - $pre) <= $margin && $pres eq $s[2]){
        ;
      }else{
        print "\n";
      }
      printf $line;
      $pre  = $s[1];
      $pres = $s[2];
    }
  }else{
    print $line;
  }
}
close FILE;
