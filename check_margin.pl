#!/usr/bin/perl -w

use strict;

my $file = shift;

my $margin = 3;

my $data;
my %num;
my $n = 0;

open FILE, "$file";
while(<FILE>){
  s/\A\s+//;
  s/\s+\Z//;
  my $line = $_;
     $line =~ s/^\#//;
     $line =~ s/\,//g;

  if(/\A\Z/){
    $n++;
  }else{
    my @s = split /\s+/, $line;

    if($s[1] =~ /\d+/){
      if(!(exists $num{$n})){ $num{$n} = 0; }
      my $i = $num{$n};

      $data->{$n}->{$i}->{chr} = $s[0];
      $data->{$n}->{$i}->{pos} = $s[1];
      $data->{$n}->{$i}->{pri} = $s[2];
      $data->{$n}->{$i}->{str} = $s[3];
      $data->{$n}->{$i}->{bre} = $s[4];
      $data->{$n}->{$i}->{dis} = $s[5];
      $data->{$n}->{$i}->{c1}  = $s[6];
      $data->{$n}->{$i}->{c2}  = $s[7];
      $data->{$n}->{$i}->{c}   = $s[6] + $s[7];
      $data->{$n}->{$i}->{f}   = 0;
      if($#s > 7){
        $data->{$n}->{$i}->{l}   = $s[8];
        $data->{$n}->{$i}->{s}   = $s[9];
        $data->{$n}->{$i}->{m}   = $s[10];
      }
      if($#s > 10){
        $data->{$n}->{$i}->{p}   = $s[11];
        $data->{$n}->{$i}->{ci}  = $s[12];
        $data->{$n}->{$i}->{di}  = $s[13];
        $data->{$n}->{$i}->{se}  = $s[14];
      }
      $num{$n} = $num{$n} + 1; 
    }else{
      print $line . "\n";
    }
  }
}
close FILE;

for(my $i = 0; $i <= $n; $i++){
  if(!(exists $num{$n})){ next; }

  foreach my $j (sort {$data->{$i}->{$main::b}->{c} <=> $data->{$i}->{$main::a}->{c}} keys %{$data->{$i}}){
    if($data->{$i}->{$j}->{f} > 0){ next; }

    foreach my $k (keys %{$data->{$i}}){
      if($j == $k){ next; }
      if($data->{$i}->{$k}->{f} > 0){ next; }

      my $d1 = abs($data->{$i}->{$j}->{pos} - $data->{$i}->{$k}->{pos});
      my $d2 = abs($data->{$i}->{$j}->{bre} - $data->{$i}->{$k}->{bre});

      if($d1 <= $margin && $d2 <= $margin){
        $data->{$i}->{$j}->{c1} = $data->{$i}->{$j}->{c1} +  $data->{$i}->{$k}->{c1};
        $data->{$i}->{$j}->{c2} = $data->{$i}->{$j}->{c2} +  $data->{$i}->{$k}->{c2};

        $data->{$i}->{$k}->{f} = 1;
      }
    }
  }
}


my $flag = 0;
for(my $i = 0; $i <= $n; $i++){
  if(!(exists $num{$n})){ next; }

  if($flag == 0){
    print "\n";
    $flag++;
  }
  foreach my $j (sort {$data->{$i}->{$main::b}->{dis} <=> $data->{$i}->{$main::a}->{dis}} keys %{$data->{$i}}){
    my $chr = $data->{$i}->{$j}->{chr};
    my $pos = $data->{$i}->{$j}->{pos};
    my $pri = $data->{$i}->{$j}->{pri};
    my $str = $data->{$i}->{$j}->{str};
    my $bre = $data->{$i}->{$j}->{bre};
    my $dis = $data->{$i}->{$j}->{dis};
    my $c1  = $data->{$i}->{$j}->{c1};
    my $c2  = $data->{$i}->{$j}->{c2};
    my $l   = 0;
    my $s   = "";
    my $m   = "";
    my $p   = 0;
    my $ci  = "";
    my $di  = "";
    my $se  = "";
    if(exists $data->{$i}->{$j}->{l}){
      $l = $data->{$i}->{$j}->{l};
      $s = $data->{$i}->{$j}->{s};
      $m = $data->{$i}->{$j}->{m};
    }
    if(exists $data->{$i}->{$j}->{p}){
      $p = $data->{$i}->{$j}->{p};
      $ci= $data->{$i}->{$j}->{ci};
      $di= $data->{$i}->{$j}->{di};
      $se= $data->{$i}->{$j}->{se};
    }

    if($data->{$i}->{$j}->{f} > 0){
      ;
    }else{
      if(exists $data->{$i}->{$j}->{l}){
        printf "%s,	%d,	%s,	%s,	%d,	%d,	%d,	%d,	%d,	%s,	%s", $chr, $pos, $pri, $str, $bre, $dis, $c1, $c2, $l, $s, $m;
        if(exists $data->{$i}->{$j}->{p}){
          printf "	%d,	%s,	%s,	%s", $p, $ci, $di, $se;
        }
        printf "\n";
      }else{
        printf "%s,	%d,	%s,	%s,	%d,	%d,	%d,	%d\n", $chr, $pos, $pri, $str, $bre, $dis, $c1, $c2;
      }
      $flag = 0;
    }
  } 
}
