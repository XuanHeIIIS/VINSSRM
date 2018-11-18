#!/usr/bin/perl -w

#
# (extract_R1R2.pl [fasta file1] [fasta file2] [new fastq file1] [new fastq file2] ) 
#

use strict;

my $file1 = shift;
my $file2 = shift;
my $out1 = shift;
my $out2 = shift;

my $seq;
my $name = "";
my $flag = 0;

my $id1 =0;
my $id2 =0;

open FILE1, "$file1";
while(<FILE1>){
  s/\A\s+//;
  s/\s+\Z//;
  my $line = $_;

#@SRR1365080.34 34 length=151 3F-LR L=71 Q=35.8
#  if(/\A\>([\W\w]+)\Z/){
  if(/\A\@(\S+) (\S+)(\s[\W\w]+)\Z/){
    $id1++;
    my $s = $line;
    my @s = split /\s+/, $s;
       $name = $s[0];
    my $prim = $s[$#s-2];
#       $s[0] = $s[0] . "_R1";

    $seq->{$name}->{"1"}->{"n"} = $name . " " . $s[$#s-2] . " R1";
    $seq->{$name}->{"1"}->{"s"} = "";
    $seq->{$name}->{"1"}->{"p"} = $prim;
    $seq->{$name}->{"1"}->{"q"} = "";
  }else{
    if($flag == 0){
      if($line =~ /\A\+\Z/){
        $flag++;
      }else{
        $seq->{$name}->{"1"}->{"s"} = $seq->{$name}->{"1"}->{"s"} . $line; 
      }
    }else{
      $seq->{$name}->{"1"}->{"q"} = $seq->{$name}->{"1"}->{"q"} . $line; 
      $flag = 0;
    }
  }
}
close FILE1;

$name = "";
$flag = 0;
open FILE2, "$file2";
while(<FILE2>){
  s/\A\s+//;
  s/\s+\Z//;
  my $line = $_;

#  if(/\A\>([\W\w]+)\Z/){
  if(/\A\@(\S+) (\S+)(\s[\W\w]+)\Z/){
    $id2++;
    my $s = $line;
    my @s = split /\s+/, $s;
       $name = $s[0];
    my $prim = $s[$#s-2];

    $seq->{$name}->{"2"}->{"n"} = $name . " " . $s[$#s-2] . " R2";
    $seq->{$name}->{"2"}->{"s"} = "";
    $seq->{$name}->{"2"}->{"p"} = $prim;
    $seq->{$name}->{"2"}->{"q"} = "";
  }else{
    if($flag == 0){
      if($line =~ /\A\+\Z/){
        $flag++;
      }else{
        $seq->{$name}->{"2"}->{"s"} = $seq->{$name}->{"2"}->{"s"} . $line; 
      }
    }else{
      $seq->{$name}->{"2"}->{"q"} = $seq->{$name}->{"2"}->{"q"} . $line; 
      $flag = 0;
    }
  }
}
close FILE2;


open OUT1, ">$out1";
open OUT2, ">$out2";

my $ido1 = 0;
my $ido2 = 0;
my $i;
foreach $i (sort {$main::a cmp $main::b} keys %{$seq}){
  if(exists $seq->{$i}->{1} && exists $seq->{$i}->{2}){
    if(($seq->{$i}->{1}->{p} eq "LF" || $seq->{$i}->{1}->{p} eq "LR" )
        && ($seq->{$i}->{2}->{p} eq "LF" || $seq->{$i}->{2}->{p} eq "LR" )){
#      printf STDERR "Both of paired-end reads did not include LTR seaquences. %s\n", $i;
      $ido1++;
      $ido2++;
    }else{
      if(!($seq->{$i}->{1}->{p} =~ /L[FR]/) 
        && !($seq->{$i}->{2}->{p} =~ /L[FR]/)){
        $ido1++;
        $ido2++;
      }else{
        printf OUT1 "%s\n%s\n\+\n%s\n", $seq->{$i}->{1}->{n}, $seq->{$i}->{1}->{s}, $seq->{$i}->{1}->{q};
        printf OUT2 "%s\n%s\n\+\n%s\n", $seq->{$i}->{2}->{n}, $seq->{$i}->{2}->{s}, $seq->{$i}->{2}->{q};
      }
    }
  }else{
#    printf STDERR "Both of paired-end reads did not include primer seaquences. %s\n", $i;
    if(exists $seq->{$i}->{1}){ $ido1++; }
    if(exists $seq->{$i}->{2}){ $ido2++; }
  }
}


printf STDERR "-------------------------------------------------------\n";
printf STDERR "Total %d seaquence reads were checked from fasta1.\n", $id1;
printf STDERR "Total %d seaquence reads were checked from fasta2.\n", $id2;
printf STDERR "%d seaquence reads were omitted from fasta1.\n", $ido1;
printf STDERR "%d seaquence reads were omitted from fasta2.\n", $ido2;
printf STDERR "%d (%d + %d) seaquence reads were outputted to new fasta file.\n", ($id1 - $ido1 + $id2 - $ido2), $id1 - $ido1, $id2 - $ido2;

