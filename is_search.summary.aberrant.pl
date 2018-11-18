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
#SRR1363270.105166 chr17 40508540 5' - 40508483 57 34 GTCTTTTCTGGGAGTGAACTAGCCCTTCCA_ATAT TAAATTGACATGTTGATGTAATTCCTTTAAATCTATTTCAGAATGTGTTTGTGTGTGT 30
    my @s = split /\s+/, $line;
    my $id   = $s[0];
    my $chr  = $s[1];
    my $pos  = $s[2];
    my $pri  = $s[3];
    my $str  = $s[4];
    my $bre  = $s[5];
    my $dis  = $s[6];
    my $seq  = $s[8];
    my $dis2 = $s[7] . "_" . $s[$#s];

    if(exists $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{$dis2}->{$seq}->{1}){
      $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{$dis2}->{$seq}->{1} = $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{$dis2}->{$seq}->{1} + 1; 
    }else{
      $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{$dis2}->{$seq}->{1} = 1;
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
#SRR1363270.102208 chr2 133020702 3' + 133020787 85 67 CCCTTTTAGTCAGTGTGGAAAATCTCTAGCAGT_AAGTGCTAATGAAGCGTAAAGACAAAGCCCTATG GATGGTGCCGGTACTCGCTAATTTTTCTGGTTAGATAGCTCTTTATTGTCACGAATTTGGTGAAAAATACTTAGGGAT GATGGTGCCGGTACTCGCTAATTTTTCTGGTTAGATAGCTCTTTATTGTCACGAATTTGGTGAAAAATACTTAGGGATGGTACCTA 33
    my @s = split /\s+/, $line;
    my $id   = $s[0];
    my $chr  = $s[1];
    my $pos  = $s[2];
    my $pri  = $s[3];
    my $str  = $s[4];
    my $bre  = $s[5];
    my $dis  = $s[6];
    my $seq  = $s[8];
    my $dis2 = $s[7] . "_" . $s[$#s];

    if(exists $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{$dis2}->{$seq}->{2}){
      $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{$dis2}->{$seq}->{2} = $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{$dis2}->{$seq}->{2} + 1; 
    }else{
      $data->{$chr}->{$pos}->{$pri}->{$str}->{$bre}->{$dis}->{$dis2}->{$seq}->{2} = 1;
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
            foreach my $o (sort {$main::a cmp $main::b} keys %{$data->{$i}->{$j}->{$k}->{$l}->{$m}->{$n}}){
              foreach my $p (sort {$main::a cmp $main::b} keys %{$data->{$i}->{$j}->{$k}->{$l}->{$m}->{$n}->{$o}}){
                if(!(exists $data->{$i}->{$j}->{$k}->{$l}->{$m}->{$n}->{$o}->{$p}->{1})){
                  $data->{$i}->{$j}->{$k}->{$l}->{$m}->{$n}->{$o}->{$p}->{1} = 0;
                }
                if(!(exists $data->{$i}->{$j}->{$k}->{$l}->{$m}->{$n}->{$o}->{$p}->{2})){
                  $data->{$i}->{$j}->{$k}->{$l}->{$m}->{$n}->{$o}->{$p}->{2} = 0;
                }

                printf "%s,	%d,	%s,	%s,	%d,	%d,", $i, $j, $k, $l, $m, $n; 
                printf "	%d,", $data->{$i}->{$j}->{$k}->{$l}->{$m}->{$n}->{$o}->{$p}->{1};
                printf "	%d,", $data->{$i}->{$j}->{$k}->{$l}->{$m}->{$n}->{$o}->{$p}->{2};
                printf "	%s,	%s\n", $o, $p;
              }
            }
          }
        }
      }
    }
  }
}


