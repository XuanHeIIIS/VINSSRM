#!/usr/bin/perl -w

use strict;

#
# usage: 
#   is_search_1r.pl (SAM file) (text file) (output) 
#
#    SAM file  : the file is generated from assembled fastq file and only contains 
#                sequences mapped to both human and viral reference sequences.
#    text file : the file includes ideal viral terminal end sequences at 3'- and 5'-ends.
#       3F  CCCTTTTAGTCAGTGTGGAAAATCT
#       5F  GTCTTTTCTGGGAGTGAACTAGCC
#       3FE CCCTTTTAGTCAGTGTGGAAAATCTCTAGCA
#       5FE GTCTTTTCTGGGAGTGAACTAGCCCTTCCA
#       (eg. for analyses of sequence data in Sience, 2014, 345, 179)
#
#    output    : the program outputs information on integration site with standard viral terminal ends.
#
#    Note:
#     the program outputs information on integration site with irregular viral terminal ends, in STDERR.
#


my $file = shift;
my $refs = shift;

my $out = shift;

open OUT, ">$out";

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

open FILE, "$file";
while(<FILE>){
  s/\A\s+//;
  s/\s+\Z//;
  my $line = $_;

  if(/\A\@/){ ; }
  else{
    my @s = split /\s+/, $line;
    my $id = $s[0];
    my @seq = split //, $s[9];

    # mapped to human genome
    if($s[2] =~ /^chr/){
      if($s[5] =~ /^\d+S\w+[A-Z]\d+S$/){ ; }
      else{
        $data->{$id}->{h}->{chr} = $s[2];
        $data->{$id}->{h}->{pos} = $s[3];
        $data->{$id}->{h}->{pri} = $s[$#s];
        $data->{$id}->{h}->{seq} = $s[9];
        $data->{$id}->{h}->{ci}  = $s[5];

        if($s[5] =~ /^(\d+)S(\w+[A-Z])$/){
          if(exists $data->{$id}->{h}->{l}){ 
            printf STDERR "DUPLICATED: %s\n", $line; 
            $data->{$id}->{h}->{l} = "";
          }
          else{ 
            $data->{$id}->{h}->{l} = $line; 
          }

          $data->{$id}->{h}->{nv}   = $1;
          $data->{$id}->{h}->{hci}  = $2;
          $data->{$id}->{h}->{type} = 1;
        }
        elsif($s[5] =~ /^(\w+[A-Z])(\d+)S$/){
          if(exists $data->{$id}->{h}->{l}){ 
            printf STDERR "DUPLICATED: %s\n", $line; 
            $data->{$id}->{h}->{l} = "";
          }
          else{ 
            $data->{$id}->{h}->{l} = $line; 
          }

          $data->{$id}->{h}->{nv}   = $2;
          $data->{$id}->{h}->{hci}  = $1;
          $data->{$id}->{h}->{type} = 2;
        }else{
          printf STDERR "Ambitious mapping pattern: %s\n", $line;
        }
      }
    }
    # mapped to HIV-1 genome
    else{
      if($s[5] =~ /^\d+S\w+[A-Z]\d+S$/){
        ;
      }
      else{
        $data->{$id}->{v}->{chr} = $s[2];
        $data->{$id}->{v}->{pos} = $s[3];
        $data->{$id}->{v}->{pri} = $s[$#s];
        $data->{$id}->{v}->{seq} = $s[9];
        $data->{$id}->{v}->{ci}  = $s[5];

        if($s[5] =~ /^(\d+)M(\w+[A-Z])$/){
          if(exists $data->{$id}->{v}->{l}){
            printf STDERR "DUPLICATED: %s\n", $line;
            $data->{$id}->{v}->{l} = "";
          }else{
            $data->{$id}->{v}->{l} = $line;
          }

          $data->{$id}->{v}->{nv} = $1;
          $data->{$id}->{v}->{hci} = $2;

          $data->{$id}->{v}->{type}= 1;
        }
        elsif($s[5] =~ /^(\w+[A-Z])(\d+)M$/){
          if(exists $data->{$id}->{v}->{l}){
            printf STDERR "DUPLICATED: %s\n", $line;
            $data->{$id}->{v}->{l} = "";
          }else{
            $data->{$id}->{v}->{l} = $line;
          }

          $data->{$id}->{v}->{nv} = $2;
          $data->{$id}->{v}->{hci} = $1;

          $data->{$id}->{v}->{type}= 2;
        }else{
          printf STDERR "Ambitious mapping pattern: %s\n", $line;
        }
      }
    }
  }
}
close FILE;

foreach my $i (sort {$main::a cmp $main::b} keys %{$data}){

  if(!(exists $data->{$i}->{h}->{nv} && exists $data->{$i}->{v}->{nv})){ next; }
  if($data->{$i}->{h}->{l} eq "" || $data->{$i}->{v}->{l} eq ""){ next; }

  my $chr  = $data->{$i}->{h}->{chr};

  if($data->{$i}->{h}->{pri} =~ /3[FR]/){
    my $pri  = "3'";
    my $diff1 = $lref3F - $data->{$i}->{h}->{nv};
    my $diff2 = $lref3F - $data->{$i}->{v}->{nv};
    my $diff3 = $data->{$i}->{h}->{nv} - length($p3F);
    my $diff4 = $data->{$i}->{h}->{nv} - $data->{$i}->{v}->{nv};

    if($diff1 >= (-1 * $margin) && $diff2 <= $margin && $diff3 > 0 && $diff4 <= $margin){
      my $nv   = $lref3F;
      my ($nv2, $pos, $str, $bre, $dist, $seqvir, $seqhu) = &detect_is($data, $i, $diff1, $p3F, 0, $nv);

      printf OUT "#%s\n", $data->{$i}->{h}->{l};
      printf OUT "#%s\n", $data->{$i}->{v}->{l};
      printf OUT "%s %s %d %s %s %d %d %d %s %s\n",   $i, $chr, $pos, $pri, $str, $bre, $dist, $nv2, $seqvir, $seqhu;
    }
    else{
      if($diff3 <= 0){ next; }

      my $nv   = $data->{$i}->{h}->{nv};
         $diff1 = 0;
      my ($nv2, $pos, $str, $bre, $dist, $seqvir, $seqhu) = &detect_is($data, $i, $diff1, $p3F, 1, $nv);

      printf STDOUT "#%s\n", $data->{$i}->{h}->{l};
      printf STDOUT "#%s\n", $data->{$i}->{v}->{l};
      printf STDOUT "%s %s %d %s %s %d %d %d %s %s %d\n",   $i, $chr, $pos, $pri, $str, $bre, $dist, $nv2, $seqvir, $seqhu, $data->{$i}->{v}->{nv};
    }
  }
  elsif($data->{$i}->{h}->{pri} =~ /5[FR]/){
    my $pri  = "5'";
    my $diff1 = $lref5F - $data->{$i}->{h}->{nv};
    my $diff2 = $lref5F - $data->{$i}->{v}->{nv};
    my $diff3 = $data->{$i}->{h}->{nv} - length($p5F);
    my $diff4 = $data->{$i}->{h}->{nv} - $data->{$i}->{v}->{nv};

    if($diff1 >= (-1 * $margin) && $diff2 <= $margin && $diff3 > 0  && $diff4 <= $margin){
      my $nv   = $lref5F;
      my ($nv2, $pos, $str, $bre, $dist, $seqvir, $seqhu) = &detect_is($data, $i, $diff1, $p5F, 0, $nv);

      printf OUT "#%s\n", $data->{$i}->{h}->{l};
      printf OUT "#%s\n", $data->{$i}->{v}->{l};
      printf OUT "%s %s %d %s %s %d %d %d %s %s\n",   $i, $chr, $pos, $pri, $str, $bre, $dist, $nv2, $seqvir, $seqhu;
    }
    else{
      if($diff3 <= 0){ next; }

      my $nv   = $data->{$i}->{h}->{nv};
         $diff1 = 0;
      my ($nv2, $pos, $str, $bre, $dist, $seqvir, $seqhu) = &detect_is($data, $i, $diff1, $p5F, 1, $nv);

      printf STDOUT "#%s\n", $data->{$i}->{h}->{l};
      printf STDOUT "#%s\n", $data->{$i}->{v}->{l};
      printf STDOUT "%s %s %d %s %s %d %d %d %s %s %d\n",   $i, $chr, $pos, $pri, $str, $bre, $dist, $nv2, $seqvir, $seqhu, $data->{$i}->{v}->{nv};
    }
  }
  else{
    printf STDERR "Primer was not found %s\n", $data->{$i}->{h}->{l};
    printf STDERR "Primer was not found: %s\n", $data->{$i}->{v}->{l};
  }
}



sub ci2num
{
  my $ci = shift;
  
  my $num = 0;

  my @d = split /[A-Z]/, $ci;
  my @s = split /\d+/, $ci;
  shift @s;

  my $i;
  for($i = 0; $i <= $#s; $i++){
    my $d = sprintf "%d", $d[$i];
    if($s[$i] eq "M"){ $num = $num + $d; } 
    elsif($s[$i] eq "I"){ $num = $num - $d; } 
    elsif($s[$i] eq "D"){ $num = $num + $d; } 
    elsif($s[$i] eq "S"){ ; }
    else{ printf STDERR "Unknown CIGAR string was found: %d%s\n", $d[$i], $s[$i]; }
  }

  return ($num);
}

sub seq2vir
{
  my $seq  = shift;
  my $nv   = shift;
  my $type = shift;
  my $flag = shift;
  my $nv_v = shift;

  my $f = 0;
  my $fx= 0;

  my $s   = "";
  
  my @seq = split //, $seq;

  my $start  = 0;
  my $stop   = $#seq;
  my $start2 = 0;
  my $stop2  = $#seq;
  if($type == 1){ 
    $stop  = $nv - 1; 
    if($flag == 1){
      $stop2 = $nv_v - 1;
      if($nv < $nv_v){ 
        $stop  = $nv_v - 1; 
        $stop2 = $nv   - 1; 
      }

      if($seq[$stop] eq "C" && $seq[$stop+1] eq "A"){
        $stop++;
        if($nv < $nv_v){ $fx = 1; }
        else           { $f  = 1; }
      }
      if($seq[$stop2] eq "C" && $seq[$stop2+1] eq "A"){
        $stop2++;
        if($nv < $nv_v){ $f  = 1; }
        else           { $fx = 1; }
      }
    }
  }
  if($type == 2){ 
    $start = $#seq - $nv + 1; 
    if($flag == 1){
      $start2 = $#seq - $nv_v + 1;
      if($nv < $nv_v){
        $start  = $#seq - $nv_v + 1;
        $start2 = $#seq - $nv   + 1;
      }

      if($seq[$start] eq "G" && $seq[$start-1] eq "T"){
        $start--;
        if($nv < $nv_v){ $fx = 1; }
        else           { $f  = 1; }
      }
      if($seq[$start2] eq "G" && $seq[$start2-1] eq "T"){
        $start2--;
        if($nv < $nv_v){ $f  = 1; }
        else           { $fx = 1; }
      }
    }
  }
  for(my $i = $start; $i <= $stop; $i++){
    $s = $s . $seq[$i];
    if($flag == 1){
      if($type == 1){
        if($stop  != $stop2  && $i == $stop2){ $s = $s . "_"; }
      }
      if($type == 2){
        if($start != $start2 && $i == $start2 - 1){ $s = $s . "_"; }
      }
    }
  }

  return($s, $f, $fx);
}

sub seq2hu
{
  my $seq  = shift;
  my $nv   = shift;
  my $type = shift;
  my $flag = shift;

  my $f = 0;

  my $s   = "";
  
  my @seq = split //, $seq;

  my $start = 0;
  my $stop  = $#seq;
  if($type == 1){ 
    $start = $nv; 
    if($flag == 1){
      if($seq[$start] eq "A" && $seq[$start-1] eq "C"){
        $start++;
        $f = 1;
      }
    }
  }
  if($type == 2){ 
    $stop  = $#seq - $nv; 
    if($flag == 1){
      if($seq[$stop] eq "T" && $seq[$stop+1] eq "G"){
        $stop--;
        $f = 1;
      }
    }
  }
  for(my $i = $start; $i <= $stop; $i++){
    $s = $s . $seq[$i];
  }

  return($s, $f);
}

sub reverse_complement_seq
{
  my $s = shift;
  my @s = split //, $s;
     @s = reverse @s;

  my $t;
  my $ss = '';
  for($t = 0; $t <= $#s; $t++){
    if($s[$t] eq 'A'){ $ss = $ss . 'T'; }
    if($s[$t] eq 'T'){ $ss = $ss . 'A'; }
    if($s[$t] eq 'G'){ $ss = $ss . 'C'; }
    if($s[$t] eq 'C'){ $ss = $ss . 'G'; }
    if($s[$t] eq '_'){ $ss = $ss . '_'; }
    if($s[$t] eq 'N'){ $ss = $ss . 'N'; }
  }

  return $ss;
}


sub detect_is
{
  my $data  = shift;
  my $id    = shift;
  my $diff  = shift;
  my $pF    = shift;
  my $eflag = shift;
  my $nv    = shift;

  my $num  = &ci2num($data->{$id}->{h}->{hci});

  my $pos; my $str; my $bre; my $dist; 
  if($data->{$id}->{h}->{type} == 1){
    $pos  = $data->{$id}->{h}->{pos} + $diff - 1;
    $bre  = $data->{$id}->{h}->{pos} + $num - 1 - 1;
    $str  = "+";
    $dist = $bre - $pos;
  }
  elsif($data->{$id}->{h}->{type} == 2){
    $bre  = $data->{$id}->{h}->{pos};
    $pos  = $data->{$id}->{h}->{pos} + $num - $diff - 1;
    $str  = "-";
    $dist = $pos - $bre;
  }
        
  my ($seqvir, $f, $fx) = &seq2vir($data->{$id}->{h}->{seq}, $nv, $data->{$id}->{h}->{type}, $eflag, $data->{$id}->{v}->{nv});
  if(!($seqvir =~ /$pF/)){ $seqvir = &reverse_complement_seq($seqvir); }
  my ($seqhu , $f2) = &seq2hu ($data->{$id}->{h}->{seq}, $nv, $data->{$id}->{h}->{type}, $eflag);
  if($f > 0){
    $dist = $dist - 1;
    $nv   = $nv   + 1;
    if($data->{$id}->{h}->{type} == 1){ $pos = $pos + 1; }
    if($data->{$id}->{h}->{type} == 2){ $pos = $pos - 1; }
  }
  if($fx > 0){
    $data->{$id}->{v}->{nv} = $data->{$id}->{v}->{nv} + 1;
  }

  return($nv, $pos, $str, $bre, $dist, $seqvir, $seqhu);
}

