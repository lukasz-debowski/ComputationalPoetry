#!/usr/bin/perl

use strict;
use Speak::Polish;

my (%hash,%cnt);
my @strange;
my ($r,$l,$m,$rm,$ml);
my $cnt;

while(<>){
    $l=$_;
    ($m,$r)= Speak::Polish::meter_and_rhyme($l);
    next if($m eq "");
    $r=~s/\(±\)$/\(o\)/;
    $r=~s/\(y\)j$/\(y\)/;
    #$r=~s/\(e\)m$/\(y\)m/;
    $rm="[$r]";
    $ml="\t[$m] $l";
    push @{$hash{$rm}}, $ml;
    $cnt{$rm}++;
    $cnt++;
    #print STDERR "$rm - $cnt{$rm}\n";
    #print STDERR $ml;
    if(( $m!~/^.{13}$/ )||
       ( $m!~/^.{5}[\!\?].{5}(\!\.|\?\?)/ )){
	push @strange, $ml;
    }
}

sub my_cmp{
    my ($a,$b)=@_;
    my $cmp=($cnt{$b}<=>$cnt{$a});
    return $cmp if($cmp!=0);
    $cmp=(reverse $b cmp reverse $a);
    return $cmp;
}

print "$cnt LINES\n\n";

print "ATYPICAL METER - ".scalar(@strange)."\n";
for $ml (sort 
	 {reverse(Speak::Polish::pronunciation($a)) 
	      cmp 
	      reverse(Speak::Polish::pronunciation($b))} 
	 @strange){
    print $ml;
}

print "\nRHYMES:\n\n";

for $rm (sort {$cnt{$b}<=>$cnt{$a}} keys %cnt){
#for $rm (sort {my_cmp($a,$b)} keys %cnt){
    print "$rm - $cnt{$rm}\n";
    for $ml (sort 
	    {reverse(Speak::Polish::pronunciation($a)) 
		 cmp 
		 reverse(Speak::Polish::pronunciation($b))} 
	    @{$hash{$rm}}){
 	print $ml;
    }
}
