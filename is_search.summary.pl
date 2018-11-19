#!/usr/bin/perl -w

use strict;

my $file_1r = shift;
my $file_2r = shift;

my $data;

open FILE1, "$file_1r";
while(<FILE1>){
  s/\A\s+//;
  s/\s+\Z//;
  my $line = $_;

  if(/\A\S+\s+chr/){
#SRR1365087.1000247 chr9 33963980 3' + 33964037 57 31 CCCTTTTAGTCAGTGTGGAAAATCTCTAGCA GACACTCAAATCACTTCAATTATTCTCATTCTCACGCCCATGTTTACCAAGCTCCCTA
    my @s = split /\s+/, $line;
    my $id   = $s[0];
    my $chr  = $s[1];
    my $pos  = $s[2];
    my $pri  = $s[3];
    my $str  = $s[4];
    my $bre  = $s[5];
    my $dis  = $s[6];

    if(exists $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{1}){
      $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{1} = $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{1} + 1; 
    }else{
      $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{1} = 1;
    }
  }
}
close FILE1;

open FILE2, "$file_2r";
while(<FILE2>){
  s/\A\s+//;
  s/\s+\Z//;
  my $line = $_;

  if(/\A\S+\s+chr/){
    my @s = split /\s+/, $line;
    my $id   = $s[0];
    my $chr  = $s[1];
    my $pos  = $s[2];
    my $pri  = $s[3];
    my $str  = $s[4];
    my $bre  = $s[5];
    my $dis  = $s[6];

    if(exists $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{2}){
      $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{2} = $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{2} + 1; 
    }else{
      $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{2} = 1;
    }
  }
}
close FILE2;

printf "chr,	position,	LTR,	strand,	break-point, distance, counts\n";
foreach my $i (sort {$main::a cmp $main::b} keys %{$data}){
  foreach my $j (sort {$main::a <=> $main::b} keys %{$data->{$i}}){
    foreach my $k (sort {$main::a cmp $main::b} keys %{$data->{$i}->{$j}}){
      foreach my $l (sort {$main::a cmp $main::b} keys %{$data->{$i}->{$j}->{$k}}){
        foreach my $m (sort {$main::a <=> $main::b} keys %{$data->{$i}->{$j}->{$k}->{$l}}){
          foreach my $n (sort {$main::a <=> $main::b} keys %{$data->{$i}->{$j}->{$k}->{$l}->{$m}}){
            if(!(exists $data->{$i}->{$j}->{$k}->{$l}->{$m}->{$n}->{1})){
              $data->{$i}->{$j}->{$k}->{$l}->{$m}->{$n}->{1} = 0;
            }
            if(!(exists $data->{$i}->{$j}->{$k}->{$l}->{$m}->{$n}->{2})){
              $data->{$i}->{$j}->{$k}->{$l}->{$m}->{$n}->{2} = 0;
            }

            printf "%s,	%d,	%s,	%s,	%d,	%d,", $i, $j, $k, $l, $m, $n; 
            printf "	%d,", $data->{$i}->{$j}->{$k}->{$l}->{$m}->{$n}->{1};
            printf "	%d\n", $data->{$i}->{$j}->{$k}->{$l}->{$m}->{$n}->{2};
          }
        }
      }
    }
  }
}


