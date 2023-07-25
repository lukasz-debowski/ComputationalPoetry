#!/usr/bin/perl

##
## TURPIS 0.5 -- The Ultimate Retriever of Poetry Ignoring Sense
##
## author: £ukasz Dêbowski, 2004,2007
##
## e-mail: ldebowsk@ipipan.waw.pl
##

use strict;
use POSIX;
use locale;


## These are the languages TURPIS can compose in:

use Speak::Polish;
use Speak::Czech;

my %pronunciation=(
    "Polish" => \&Speak::Polish::pronunciation,
    "Czech"  => \&Speak::Czech::pronunciation
);

my %meter_and_rhyme=(
    "Polish" => \&Speak::Polish::meter_and_rhyme,
    "Czech"  => \&Speak::Czech::meter_and_rhyme
);

my $language="Polish"; # default

##

my $batchmode;

## filenames

my $verseDB="turpis_base_";
my $theoryDB="turpis_theory_";

##

my (%syllable_types,%verse_syllables,%stanza_verses);
my (%syllable_types_e,%verse_syllables_e,%stanza_verses_e);
my %verse_data_base;
my ($maximal_verse_length,$minimal_verse_length);

sub open_theory_data_base{
    my $file=shift;
    print "Clearing the theory database.\n" if(!$batchmode);
    %syllable_types=();
    %verse_syllables=();
    %stanza_verses=();
    %syllable_types_e=();
    %verse_syllables_e=();
    %stanza_verses_e=();
    print "Reading file $file...\n" if(!$batchmode);
    open(IN,$file);
    my ($mode,@tab);
    while(<IN>){
	chomp;
	s/\#.*$//g;
	s/^\s+//g;
	s/\s+$//g;
	next if($_ eq "");
	@tab=split;
	if(@tab==1){
	    $mode=$tab[0];
	}elsif($mode eq "SYLLABLES"){
	    my ($zt, $regexp, $name)=@tab;
	    $syllable_types{$zt}=join("\t",$regexp, $name);
	    $syllable_types_e{$zt}=[$regexp, $name];
	}elsif($mode eq "VERSES"){
	    my ($vt, $regexp)=@tab;
	    $verse_syllables{$vt}=join("\t",$regexp);
	    my $long=$regexp;
	    $long=~s/(.)\?/\1/g;
	    my $max=length($long);
	    my $short=$regexp;
	    $short=~s/(.)\?//g;
	    my $min=length($short);
	    if((!defined $maximal_verse_length)
	       ||($maximal_verse_length<$max)){
		$maximal_verse_length=$max;
	    }
	    if((!defined $minimal_verse_length)
	       ||($minimal_verse_length>$min)){
		$minimal_verse_length=$min;
	    }
	    my @symbol=split //,$regexp;
	    my @nsymbol;
	    my $l;
	    for $l (@symbol){
		if(exists $syllable_types_e{$l}){
		    push @nsymbol, $syllable_types_e{$l}[0];
		}else{
		    push @nsymbol, $l;
		}
	    }
	    $verse_syllables_e{$vt}=join "", @nsymbol;
	}elsif($mode eq "STANZAS"){
	    my ($st, $regexp)=@tab;
	    $stanza_verses{$st}=$regexp;
	    my @verse=split /_/,$regexp;
	    my @nverse;
	    my $v;
	    for $v (@verse){
		if($v=~/^(\;)()$/){
		    my ($vt,$ri)=($1,$2);
		    push @nverse, [$vt,$ri];
		}elsif($v=~/^(\!)(\d+)$/){
		    my ($vt,$ri)=($1,$2);
		    push @nverse, [$vt,$ri];
		}elsif($v=~/^([A-Z\d]+)([a-z]+)$/){
		    my ($vt,$ri)=($1,$2);
		    push @nverse, [$vt,$ri];
		}
	    }
	    $stanza_verses_e{$st}=[@nverse];	    
	}
    }
    close(IN);
}

sub print_theory_data_base{
    print "\n";
    print "Recognized types of syllables:\n";
    my $zt;
    for $zt (sort keys %syllable_types){
	print " $zt:\t $syllable_types{$zt}\n";
    }
    print "Recognized types of verses:\n";
    my $vt;
    for $vt (sort keys %verse_syllables){
	print " $vt:\t $verse_syllables{$vt}\n";
    }
    print "Recognized types of stanzas:\n";
    my $st;
    for $st (sort keys %stanza_verses){
	print " $st:   \t $stanza_verses{$st}\n";
    }
    print "\n";
}

sub excerpt_verses{
    my $file=shift;
    print "Reading file $file assuming it's in $language...\n";
    open(IN,$file);
    my @words;
    my $word;
    while(<IN>){
	$_="\L$_";
	s/[\.\,\:\;\-\?\!\"\(\)\d\*]//go;
	s/\s+/ /go;
	#print ".";
	#print;
	for $word (split){
	    push @words,$word;
	  SHIFT1:
	    while(1){
		my $words=join " ",@words;
		my ($m,$r)=&{$meter_and_rhyme{$language}}($words);
		last SHIFT1 unless(length($m)>$maximal_verse_length);
		shift @words;
	    }
	    my @somewords=@words;
	    #print "\n";
	  SHIFT2:
	    while(1){
		last if(!@somewords);
		my $words=join " ",@somewords;
		my $w=&{$pronunciation{$language}}($somewords[$#somewords]);
		my ($m,$r)=&{$meter_and_rhyme{$language}}($words);
		last SHIFT2 if(length($m)<$minimal_verse_length);
		#print "$m $r $w $words\n";
		
		my $vt;
		for $vt (keys %verse_syllables_e){
		    my $regexp=$verse_syllables_e{$vt};
		    #print "'$m' '$regexp'\n";
		    if($m=~/^$regexp$/){
			undef $verse_data_base{$vt}{$r}{$w}{$words};
			#print "$m $r $w $words\n";
		    }
		}

		shift @somewords;
	    }
	}
    }
    close(IN);
    print "\n";
}

sub clear_verse_data_base{
    %verse_data_base=();
}

sub open_verse_data_base{
    my $file=shift;
    print "Reading file $file...\n" if(!$batchmode);
    open(IN,$file);
    my ($vt,$r,$w);
    while(<IN>){
	chomp;
	if(/\# (.*)/){
	    ($vt,$r,$w)=split / /,$1;
	}else{
	    undef $verse_data_base{$vt}{$r}{$w}{$_};
	}
    }
    close(IN);
}

sub save_verse_data_base{
    my $file=shift;
    print "Writing file $file...\n" if(!$batchmode);
    open(OUT,">$file");
    my ($vt,$r,$w,$words);
    for $vt (sort keys %verse_data_base){
	for $r (sort keys %{$verse_data_base{$vt}}){
	    next if((keys %{$verse_data_base{$vt}{$r}})<2);
	    for $w (sort keys %{$verse_data_base{$vt}{$r}}){
		print OUT "# $vt $r $w\n";
		for $words (sort keys %{$verse_data_base{$vt}{$r}{$w}}){
		    print OUT "$words\n";
		}
	    }
	}
    }
    close(OUT);
}

sub toss_some_key{
    my ($rhash)=@_;
    my @remained=keys %{$rhash};    
    my $i=POSIX::floor rand (@remained);
    return $remained[$i];
}    

sub toss_some_key_but_not_the_used_or_bad_key{
    my ($rhash,$usedhash,$badhash)=@_;
    my ($key,@remained);
    for $key (keys %{$rhash}){
	if((!exists ${$usedhash}{$key})&&(!exists ${$badhash}{$key})){
	    push @remained, $key;
	}
    }
    if(@remained){
	my $i=POSIX::floor rand (@remained);
	$key=$remained[$i];
	undef ${$usedhash}{$key};
	return $key; 
    }else{
	return undef;
    }
}    

sub toss_some_key_but_not_the_used_key{
    my ($rhash,$usedhash)=@_;
    my ($key,@remained);
    for $key (keys %{$rhash}){
	if(!exists ${$usedhash}{$key}){
	    push @remained, $key;
	}
    }
    if(@remained){
	my $i=POSIX::floor rand (@remained);
	$key=$remained[$i];
	undef ${$usedhash}{$key};
	return $key; 
    }else{
	return undef;
    }
}    

sub toss_some_keys{
    # selects at random $n keys from %{$rhash}
    my ($n,$rhash)=@_;
    my @remained=keys %{$rhash};
    my @chosen;
    while(@remained){
	last if(@chosen==$n);
	my $i=POSIX::floor rand @remained;
	push @chosen,$remained[$i];
	while(defined $remained[$i+1]){
	    $remained[$i]=$remained[$i+1];
	    $i++;
	}
	pop @remained;
    }
    return @chosen;
}

sub write_stanza_greedily{
    my $st=shift;
    my $v;
    my $success=0;
    my $maxattempt=1000;
    my $attempt=1;
    my %badrir;
    my @v;
  ATTEMPT:
    while($attempt<$maxattempt){
	$attempt++;
	@v=();
	my %r;
	my %w;
	my %rir;
      IN:
	for $v (@{$stanza_verses_e{$st}}){
	    my ($vt,$ri)=@{$v};
	    if($vt eq ";"){
		push @v, "";
	    }elsif($vt eq "!"){
		#print STDERR "$ri $v[$ri-1]\n";
		push @v, $v[$ri-1];
	    }else{
		if(!exists $rir{$ri}){
		    my $r=toss_some_key_but_not_the_used_or_bad_key 
			$verse_data_base{$vt}, \%r, \%{$badrir{$ri}};
		    if(!defined $r){
			push @v, 
			"... I don't know any different rhyme for verse '$vt'!";
			next ATTEMPT;
		    } 
		    $rir{$ri}=$r;
		}
		if(!exists $verse_data_base{$vt}{$rir{$ri}}){
		    push @v, 
		    "... I don't know any rhyme '$rir{$ri}' for verse '$vt'!";
		    undef $badrir{$ri}{$rir{$ri}};
		    next ATTEMPT;
		}		
		my $w=toss_some_key_but_not_the_used_key 
		    $verse_data_base{$vt}{$rir{$ri}}, \%w;
		if(!defined $w){
		    push @v, 
		    "... I don't know any different word for verse '$vt' and rhyme '$rir{$ri}'!";
		    next ATTEMPT;
		} 
		my $words=toss_some_key $verse_data_base{$vt}{$rir{$ri}}{$w};
		push @v, $words;
	    }
	}
	$success=1;
	last;
    }
    if($batchmode){
	print join("\n",@v)."\n";
    }else{
	print join("\n\t","",@v,"")."\n";
    }
    return ($success,$attempt);
}

sub write_stanza{
    my $st=shift;
    my $v;
    if(!exists $stanza_verses_e{$st}){
	print "I don't know how to write '$st'!\n";
	return;
    }
    for $v (@{$stanza_verses_e{$st}}){
	my ($vt,$ri)=@{$v};
	if($vt eq ";"){
	    # ignore
	}elsif($vt eq "!"){
	    # ignore	    
	}elsif(!exists $verse_data_base{$vt}){
	    print "I don't know any verse of type '$vt'!\n";
	    return;
	}
    }
    print "Writing '$st':\n";
    my ($success,$attempt)=write_stanza_greedily($st);
    if(!$success){
	print "I failed to compose in $attempt attempts!\n";
    }else{
	print "I composed in $attempt attempts.\n";
    }
}    

sub write_any_kind_of_stanza{
    my $st;
    $st=toss_some_key(\%stanza_verses_e);
    write_stanza($st);
    return $st;
}

sub welcome{
    print "\n";
    print " TURPIS 0.5 -- The Ultimate Retriever of Poetry Ignoring Sense\n";
    print " (c) £ukasz Dêbowski 2004,2007\n";
    print " e-mail: ldebowsk\@ipipan.waw.pl\n";
    print "\n";
    print "Languages served: ".join(", ",sort keys %pronunciation)."\n";
    print "\n";
    print "To run in batch mode please write:\n";
    print "\n";
    print "    turpis.pl THEORY_DB_EXTENSION VERSE_BD_EXTENSION STANZA\n";
    print "\n";
}

sub menu{
    my $st=shift;
    print "Menu: \n\n";
    print " q - quit\n";
    print " n - open a theory database (clears the current one)\n";
    if(%stanza_verses!=()){
	print "\n";
	print " h - print the theory database\n";
	print " e - excerpt a text\n";
	print " o - open a verse database (appends the opened base to the current one)\n";
	if(%verse_data_base!=()){
	    print "\n";
	    print " c - clear the verse database\n";
	    print " s - save the verse database\n";
	    print " w - write a given kind of stanza\n";
	    print " r - write a random kind of stanza\n";
	    if(defined $st){
		print " p - write the previous kind of stanza\n";
	    }
	}
    }
    print "\n";
    print "?> ";
}

# main

if(@ARGV){
    ## batch mode
    $batchmode=1;
    my ($TDBext,$VDBext,$st)=(shift,shift,shift);
    open_theory_data_base($theoryDB.$TDBext);
    open_verse_data_base($verseDB.$VDBext);
    write_stanza_greedily($st);
}else{
    ## interactive mode
    $batchmode=0;
    welcome;
    open_theory_data_base($theoryDB."default");
    #print_help;
    my ($st,$ext);
    menu($st);
    while(<>){
	chomp;
	if($_ eq "q"){
	    last;
	}elsif($_ eq "n"){
	    print "Please write the extension of the theory database to open: $theoryDB";
	    $_=<>;
	    chomp;	
	    $ext=$_;
	    open_theory_data_base($theoryDB.$ext);
	}elsif(%stanza_verses!=()){
	    if($_ eq "h"){
		print_theory_data_base;
	    }elsif($_ eq "e"){
		print "Please choose the language of the excerpted text (".
		    join(", ",sort keys %pronunciation)."): ";
		$language=<>;
		chomp $language;
		while(!exists $pronunciation{$language}){
		    print "Please choose a language I know (".
			join(", ",sort keys %pronunciation)."): ";
		    $language=<>;
		    chomp $language;
		}		
		print "Please write the filename to excerpt from: ";
		$_=<>;
		chomp;	
		excerpt_verses($_);
	    }elsif($_ eq "o"){
		print "Please write the extension of the verse database to open: $verseDB";
		$_=<>;
		chomp;	
		$ext=$_;
		open_verse_data_base($verseDB.$ext);
	    }elsif(%verse_data_base!=()){
		if($_ eq "c"){
		    print "The verse database is cleared.\n";
		    clear_verse_data_base;
		}elsif($_ eq "s"){
		    print "Please write the extension of the verse database to save: $verseDB";
		    $_=<>;
		    chomp;	
		    $ext=$_;
		    save_verse_data_base($verseDB.$ext);
		}elsif($_ eq "w"){
		    print "Please write the type of stanza to compose: ";
		    $_=<>;
		    chomp;
		    $st=$_;
		    write_stanza($st);
		}elsif($_ eq "r"){
		    $st=write_any_kind_of_stanza;
		}elsif(defined $st){
		    if($_ eq "p"){
			write_stanza($st);
		    }
		}
	    }
	}
	menu($st);
    }
}
exit;

# end of main
