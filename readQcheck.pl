#!/usr/bin/perl -w

#
# (readqualcheck.pl [fastq file] [primer txt] > [fastq file] ) &> [error txt]
#


use strict;

my $file = shift;
my $primer = shift;

###
### Minimum length of read
###
my $limitL = 5;
#my $limitL = shift;

###
### Minimum average quality scores of read
###
my $limitQ = 20;
#my $limitQ = shift;


###
### Sequences of primer set
###
my $primer3F;
my $primer5F;
my $primerlF;

###
### Read primer txt
###
open PRIM, "$primer";
while(<PRIM>){
  s/\A\s+//;
  s/\s+\Z//;
  my $line = $_;

  if(/\A3F\s+(\w+)\Z/){
    $primer3F = $1;
  }elsif(/\A5F\s+(\w+)\Z/){
    $primer5F = $1;
  }elsif(/\ALF\s+(\w+)\Z/){
    $primerlF = $1;
  }
}
close PRIM;


### Reverse complement sequences of above-defined sequences
my $primer3R  = &reverse_complement_seq($primer3F);
my $primer5R  = &reverse_complement_seq($primer5F);
my $primerlR  = &reverse_complement_seq($primerlF);

my $id = -1;
my $flag = 0;
my $seq;
my $Nomit  = 0;

###
### Read input file
###
if($file =~ /.gz$/){
  open FILE, "/usr/bin/gunzip -cd $file |";
}else{
  open FILE, "$file";
}
while(<FILE>){
  s/\A\s+//;
  s/\s+\Z//;
  my $line = $_;

  if($flag == 0){
    if(/\A\@([\W\w]+)\Z/){
      $id++;
      $seq->{$id}->{"name"} = $1;
    }else{
      $flag = 1;
      $seq->{$id}->{"seq"} = $line;
    }
  }elsif($flag == 1){
    if(/\A\+/){
      $flag = 2;
    }
  }elsif($flag == 2){
      $flag = 0;
      $seq->{$id}->{"qual"} = $line;
  }
}
close FILE;



###
### Extract target sequences including primer sequences
### 
my $i;
for($i = 0; $i <= $id; $i++){
  if($seq->{$i}->{seq} =~ /\A([\W\w]*${primerlF})([\W\w]+)\Z/){
    my $p1 = $1;
    my $s = $2;

    if($s =~ /\A([\W\w]+${primer3R})[\W\w]*\Z/){
      $s = $1;
    
      &extract_seq($p1, $s, $seq->{$i}->{qual}, $seq->{$i}->{name}, "LF", "3R");
    }
    elsif($s =~ /\A([\W\w]+${primer5R})[\W\w]*\Z/){
      $s = $1;
    
      &extract_seq($p1, $s, $seq->{$i}->{qual}, $seq->{$i}->{name}, "LF", "5R");
    }
    else{
      &extract_seq2($p1, $s, $seq->{$i}->{qual}, $seq->{$i}->{name}, "LF");
    }
  }

  elsif($seq->{$i}->{seq} =~ /\A([\W\w]*)(${primer5F}[\W\w]+)\Z/){
    my $p1 = $1;
    my $s = $2;

    if($s =~ /\A([\W\w]+)${primerlR}[\W\w]*\Z/){
      $s = $1;

      &extract_seq($p1, $s, $seq->{$i}->{qual}, $seq->{$i}->{name}, "5F", "LR");
    }
    else{
      &extract_seq2($p1, $s, $seq->{$i}->{qual}, $seq->{$i}->{name}, "5F");
    }
  }

  elsif($seq->{$i}->{seq} =~ /\A([\W\w]*)(${primer3F}[\W\w]+)\Z/){
    my $p1 = $1;
    my $s = $2;

    if($s =~ /\A([\W\w]+)${primerlR}[\W\w]*\Z/){
      $s = $1;

      &extract_seq($p1, $s, $seq->{$i}->{qual}, $seq->{$i}->{name}, "3F", "LR");
    }
    else{
      &extract_seq2($p1, $s, $seq->{$i}->{qual}, $seq->{$i}->{name}, "3F");
    }
  }

  elsif($seq->{$i}->{seq} =~ /\A([\W\w]+)${primerlR}[\W\w]*\Z/){
    my $s = $1;

    if($s =~ /\A([\W\w]*)(${primer5F}[\W\w]+)\Z/){
      my $p1 = $1;
         $s  = $2;
     
      &extract_seq($p1, $s, $seq->{$i}->{qual}, $seq->{$i}->{name}, "5F", "LR");
    }
    elsif($s =~ /\A([\W\w]*)(${primer3F}[\W\w]+)\Z/){
      my $p1 = $1;
         $s  = $2;
     
      &extract_seq($p1, $s, $seq->{$i}->{qual}, $seq->{$i}->{name}, "3F", "LR");
    }
    else{
      my $p1 = "";
      &extract_seq2($p1, $s, $seq->{$i}->{qual}, $seq->{$i}->{name}, "LR");
    }
  }

  elsif($seq->{$i}->{seq} =~ /\A([\W\w]+${primer5R})[\W\w]*\Z/){
    my $s = $1;

    if($s =~ /\A([\W\w]*${primerlF})([\W\w]+)\Z/){
      my $p1 = $1;
         $s  = $2;

      &extract_seq($p1, $s, $seq->{$i}->{qual}, $seq->{$i}->{name}, "LF", "5R");
    }
    else{
      my $p1 = "";
      &extract_seq2($p1, $s, $seq->{$i}->{qual}, $seq->{$i}->{name}, "5R");
    }
  }

  elsif($seq->{$i}->{seq} =~ /\A([\W\w]+${primer3R})[\W\w]*\Z/){
    my $s = $1;

    if($s =~ /\A([\W\w]*${primerlF})([\W\w]+)\Z/){
      my $p1 = $1;
         $s  = $2;

      &extract_seq($p1, $s, $seq->{$i}->{qual}, $seq->{$i}->{name}, "LF", "3R");
    }
    else{
      my $p1 = "";
      &extract_seq2($p1, $s, $seq->{$i}->{qual}, $seq->{$i}->{name}, "3R");
    }
  }

  else {
#    printf STDERR "Sequence did not include primer sequences we listed up. %s: %s\n", $seq->{$i}->{name}, $seq->{$i}->{seq};
    $Nomit++;
  }
}

printf STDERR "-------------------------------------------------------\n";
printf STDERR "Total %d seaquence reads were checked.\n", $id + 1;
printf STDERR "Total %d seaquence reads were omitted.\n", $Nomit;
printf STDERR "%d seaquence reads were outputted to new fasta file.\n", ($id+1) - $Nomit;





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
    if($s[$t] eq 'N'){ $ss = $ss . 'N'; }
  }  
  
  return $ss;
}

sub extract_seq
{
  my $p1 = shift;
  my $s  = shift; 
  my $q  = shift; 
  my $name   = shift;
  my $labelF = shift;
  my $labelR = shift;

  my @q  = split //, $q;

  if(length($s) > $limitL){
    my $qual = &qcheck($p1, $s, $q);
 
    if($qual > $limitQ){
      print "@";
      printf "%s %s-%s L=%d Q=%.1f\n%s\n", $name, $labelF, $labelR, length($s), $qual, $s;
      print "+\n";
      my $i;
      for($i = length($p1); $i < length($p1) + length($s); $i++){
        printf "%s", $q[$i];
      }print "\n";
    }else{
#      printf STDERR "Sequence has lower averaged quality (%.1f) score than %.1f\. %s: %s\n", $qual, $limitQ, $name, $s2;
      $Nomit++;
    }
  }else{
#    printf STDERR "Sequence length (%d) was shorter than %d. %s: %s\n", length($s2), $limitL, $name, $s2;
    $Nomit++;
  }
}
      
sub extract_seq2
{
  my $p1 = shift;
  my $s  = shift;
  my $q  = shift;
  my $name   = shift;
  my $label  = shift;

  my @q  = split //, $q;

  if(length($s) > $limitL){
    my $qual = &qcheck($p1, $s, $q);

    if($qual > $limitQ){
      print "@";
      printf "%s %s L=%d Q=%.1f\n%s\n", $name, $label, length($s), $qual, $s;
      print "+\n";
      my $i;
      for($i = length($p1); $i < length($p1) + length($s); $i++){
        printf "%s", $q[$i];
      }print "\n";
    }else{
#      printf STDERR "Sequence has lower averaged quality (%.1f) score than %.1f\. %s: %s\n", $qual, $limitQ, $name, $s;
      $Nomit++;
    }
  }else{
#    printf STDERR "Sequence length (%d) was shorter than %d. %s: %s\n", length($s), $limitL, $name, $s;
    $Nomit++;
  }
}

sub qcheck
{
  my $p = shift;
  my $s = shift;
  my $q = shift;

  my @qu = split //, $q;

  my $lp = length($p);
  my $ls = length($s);

  my $qual = 0;
  my $i;
  my $n = 0;
  for($i = $lp; $i < $lp+$ls; $i++){
    my $qs = $qu[$i];
    $qual = $qual + ord("$qs") - 33;
    $n++;
  }
  $qual = $qual / $n;

  return $qual;
}

