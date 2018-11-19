#!/usr/bin/perl -w

use strict;

#
# usage: 
#   pre_is_search_2r.pl (SAM file) (output)
#
#    SAM file  : the file is generated from assembled fastq file and only contains 
#                sequences mapped to both human and viral reference sequences.
#


my $file = shift;
my $out  = shift;

open OUT, ">$out";

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

    if($s[5] =~ /^\d+S\w+[A-Z]\d+S$/){ next; }
    if($s[5] =~ /^\*$/){ next; }

    if($s[2] =~ /^chr/){
      if($s[$#s] =~ /^R1$/){ 
        if(exists $data->{$id}->{h1}){
          printf STDERR "DUPLICATED: %s\n", $line;
          $data->{$id}->{h1} = "";
        }else{
          $data->{$id}->{h1} = $line; 
          $data->{$id}->{c1} = $s[2];
        }
      }
      elsif($s[$#s] =~ /^R2$/){ 

        if(exists $data->{$id}->{h2}){
          printf STDERR "DUPLICATED: %s\n", $line;
          $data->{$id}->{h2} = "";
        }else{
          $data->{$id}->{h2} = $line; 
          $data->{$id}->{c2} = $s[2];
        }
      }
      else{
        printf STDERR "#Something wrong: $line\n";
      }
    }else{
      if($s[$#s] =~ /^R1$/){ 
        $data->{$id}->{v1} = $line; 
      }
      elsif($s[$#s] =~ /^R2$/){ 
        $data->{$id}->{v2} = $line; 
      }
      else{
        printf STDERR "#Something wrong: $line\n";
      }
    }
  }
}

foreach my $i (sort {$main::a cmp $main::b} keys %{$data}){
  if(exists $data->{$i}->{v1} && exists $data->{$i}->{v2}){
    ;
#    printf STDERR "Something wrong: %s\n", $data->{$i}->{v1};
#    printf STDERR "Something wrong: %s\n", $data->{$i}->{v2};
  }else{
    if(exists $data->{$i}->{v1}){
      if(exists $data->{$i}->{h1} && exists $data->{$i}->{h2}){
        if($data->{$i}->{h1} eq "" || $data->{$i}->{h2} eq ""){ next; }
        if($data->{$i}->{c1} ne $data->{$i}->{c2}){ next; }

        printf OUT "%s\n", $data->{$i}->{h1};
        printf OUT "%s\n", $data->{$i}->{v1};
        printf OUT "%s\n", $data->{$i}->{h2};
      }else{
#        printf STDERR "Something wrong: %s\n", $data->{$i}->{v1};
        if(exists $data->{$i}->{h1}){
          ;
#          printf STDERR "Something wrong: %s\n", $data->{$i}->{h1};
        }
        if(exists $data->{$i}->{h2}){
          ;
#          printf STDERR "Something wrong: %s\n", $data->{$i}->{h2};
        }
      }
    }
    elsif(exists $data->{$i}->{v2}){
      if(exists $data->{$i}->{h1} && exists $data->{$i}->{h2}){
        if($data->{$i}->{h1} eq "" || $data->{$i}->{h2} eq ""){ next; }
        if($data->{$i}->{c1} ne $data->{$i}->{c2}){ next; }

        $data->{$i}->{h2} =~ s/R2$/R1/;
        $data->{$i}->{v2} =~ s/R2$/R1/;
        $data->{$i}->{h1} =~ s/R1$/R2/;

        printf OUT "%s\n", $data->{$i}->{h2};
        printf OUT "%s\n", $data->{$i}->{v2};
        printf OUT "%s\n", $data->{$i}->{h1};
      }else{
#        printf STDERR "Something wrong: %s\n", $data->{$i}->{v2};
        if(exists $data->{$i}->{h1}){
          ;
#          printf STDERR "Something wrong: %s\n", $data->{$i}->{h1};
        }
        if(exists $data->{$i}->{h2}){
          ;
#          printf STDERR "Something wrong: %s\n", $data->{$i}->{h2};
        }
      }
    }
  }
}

