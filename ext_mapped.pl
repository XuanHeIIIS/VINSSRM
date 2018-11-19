#!/usr/bin/perl -w

use strict;

my $file = shift;

my $flag1 = 0;
my $flag2 = 0;

my $pre = "";
my $l   = "";

my %list;

open FILE, "$file";
while(<FILE>){
  my $line = $_;

  if(/\A\@/){
    print $line;
  }else{
    my @s = split /\s+/, $line;

    my $i = $s[0];
    my $f = $s[2];
    my $r = $s[$#s];

    if($i ne $pre){
      if($flag1 > 0 && $flag2 > 0){ print $l; }

      $flag1 = 0;
      $flag2 = 0;
      $l     = "";
    }

    if($f =~ /^chr/) { $flag1++; }
    else{
      if(!($f =~ /^\*$/)){ $flag2++; }
    }

    $pre   = $i;

    if($flag2 > 1 && !($f =~ /^chr/ || $f =~ /^\*$/)){ ; }
    else{
      $l     = $l . $line;
    }
  }
}
close FILE;

if($flag1 > 0 && $flag2 > 0){ print $l; }


