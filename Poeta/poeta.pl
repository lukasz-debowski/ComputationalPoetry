#!/usr/bin/perl

use strict;
use POSIX;
#use speak::Polish;
#use Refstruct;

open(IN,"reguly.txt");
undef $/;
my $cfg=<IN>;
$cfg=~s/\n/ /go;
$cfg=~s/\s+/ /go;
$cfg=~s/^\s+//go;
$cfg=~s/\s+$//go;
$cfg=~s/ ?\| ?/|/go;
$cfg=~s/ ?= ?/=/go;
$cfg=~s/ ([^|= ]*=)/;\1/go;
$cfg=~s/ /+/go;
$cfg=~s/_/ /go;
#print $cfg;

my %cfg;
my $rule;
for $rule (split /;/,$cfg){
    my ($lhs,$rhs)=split /\=/,$rule;
    my @rhs=split /\|/,$rhs;
    my $i;
    for $i (0..$#rhs){
	$rhs[$i]=[split /\+/,$rhs[$i]];
    }
    $cfg{$lhs}=[@rhs];
}
my $empty='\\0';
$cfg{$empty}=[[]];
#print Refstruct::show(\%cfg);
my $start;

sub toss_some_item{
    my $i=POSIX::floor rand (@_);
    return $_[$i];
}    


sub expand{
    my ($lhs)=@_;
    if(!defined($cfg{$lhs})){
	return "$lhs ";
    }else{
	my $text;
	my @rhs=@{toss_some_item(@{$cfg{$lhs}})};
	my $lhs2;
	for $lhs2 (@rhs){
	    $text=$text.expand($lhs2);
	    if($lhs eq $start){
		$text=$text."\n";
	    }
	}
	return $text;
    }
}

$start="WIERSZ";
print expand($start);

#$start="WERS";
#print expand($start);

# $start="WERS";
# my @lines=qw(
# 	  .....
# 	  .......
# 	  .....
# 	  );
# my ($line,$text,$m,$r);
# for $line (@lines){
#     do{
# 	$text=expand($start);
# 	($m,$r)=speak::Polish::meter_and_rhyme($text);
#     }until($m=~/^$line$/);
#     print $text;
# }


# $start="WERS";
# my ($line,$text);
# for $line (1..8){
#     do{
# 	$text=expand($start);
#     }until(length($text)==82);
#     print $text;
# }



# my %i_cfg;
# my @terminals;
# my ($lhs,$i,$i2);
# for $lhs (keys %cfg){
#     for $i (0..$#{$cfg{$lhs}}){
# 	for $i2 (0..$#{$cfg{$lhs}[$i]}){
# 	    my $lhs2=$cfg{$lhs}[$i][$i2];
# 	    if(!defined($cfg{$lhs2})){
# 		push @terminals, $lhs2;
# 	    }
# 	    push @{$i_cfg{$lhs2}},[$lhs,$i,$i2];
# 	}
#     }	
# }

# my $max_l=60;
# my %enriched_l;
# my %cfg_l;
# sub enrich_l{
#     my ($lhs)=@;
#     if(!defined($enriched_l{$lhs})){
# 	if(!defined($cfg{$lhs})){
# 	    $enriched_l{$lhs}=length($lhs)+1;
# 	}else{
#  	    my $i; 
#  	    for $i (0..$#{$cfg{$lhs}}){
#  		my @rhs=@{$cfg{$lhs}[$i]};
# 	    }
# 	}
#     }	
# }

# sub enrich_all_l{
#     my $lhs;
#     for $lhs (keys %cfg){
# 	enrich_l($lhs);
#     }
# }


# my %last_t;
# sub last_t{
#     my ($lhs)=@_;
#     if(!defined($last_t{$lhs})){
# 	my @last_t;
# 	if(!defined($cfg{$lhs})){
# 	    undef $last_t{$lhs}{$lhs};
# 	}else{
# 	    my $i; 
# 	    for $i (0..$#{$cfg{$lhs}}){
# 		my @rhs=@{$cfg{$lhs}[$i]};
# 		if(@rhs){
# 		    my $t;
# 		    for $t (last_t($rhs[$#rhs])){
# 			undef $last_t{$lhs}{$t};
# 		    }
# 		}else{
# 		    undef $last_t{$lhs}{$empty};
# 		}
# 	    }
# 	}
#     }
#     my @last_t=keys %{$last_t{$lhs}};
#     #print "$lhs -> @last_t\n";
#     return @last_t;
# }

# my $lhs;
# for $lhs ("DLUGI","KROTKI","FRAZA"){
#     my @last_t=last_t($lhs);
#     print "$lhs -> @last_t\n";
# }

