#!/usr/bin/perl

use locale;
use strict;
use Speak::Polish;
use Speak::Czech;

my @languages=qw(Polish Czech);
my %languages;
map {undef $languages{$_}; } @languages;

while(1){
    print "Please select the language (",join(", ",keys %languages),")",".\n ";
    $_=<>;
    chomp;
    last if exists $languages{$_};
}

print "\nPlease write some text in $_.\n";
if($_ eq "Polish"){
    Speak::Polish::demo;
}elsif($_ eq "Czech"){
    Speak::Czech::demo;
}
