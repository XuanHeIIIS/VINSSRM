#!/usr/bin/perl -w

use strict;

my $file = shift;

my $flag = 0;

open FILE, "$file";
while(<FILE>){
  my $line = $_;

  if(/^\@/){
    $flag = 0;
    if($line =~ /\s+[35L]F\-[35L]R\s+/){
      $flag++;
      my @l = split /\s+/, $line;
      if($flag > 0){ printf "%s %s\n", $l[0], $l[$#l-2]; }
    }
  }else{
    if($flag > 0){ print $line; }
  }
}
close FILE;
