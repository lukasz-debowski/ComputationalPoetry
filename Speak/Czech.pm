package Speak::Czech;

##
## maintainer: Alexandr Rosen, 2004
##
## e-mail: alexandr.rosen@ff.cuni.cz
##

## This package provides Czech phonetic transcription and rhyme detection

use locale;
use strict;

use Exporter;
our (@ISA, @EXPORT, @EXPORT_OK);
@ISA         = qw(Exporter);
@EXPORT      = qw( &pronunciation
		   &phonetic_assimilations
                   &vowels_and_clusters
                   &stressed_pronunciation
                   &meter_and_rhyme
                   &demo
);
@EXPORT_OK   = qw( 
);

# This is the phonetic alphabet we use:

our @vowels=qw(a á e é i í o ó u ú);
our @obstruents
    =qw(
	p b
	f v
	t d
	» ï 
	s z
	¹ ¾
	è J
	k g
	x h
	);
our @liquids=qw(m n ò N r ø l j w);

## N does not seem to be needed for Czech, at least not at the moment

# End of phonetic alphabet.

our (@unvoiced,@voiced);

while(@obstruents){
    push @unvoiced, shift @obstruents;
    push @voiced, shift @obstruents;
}

our $liquidsre="(".join("|",@liquids).")";
our $vowelsre="(".join("|",@vowels).")";

our $unvoicedre="(".join("|",@unvoiced).")";
our $voicedre="(".join("|",@voiced).")";

our (%vowel,%unvoiced,%voiced,%liquid);
our $i;

for $i (0..$#vowels){
    undef $vowel{$vowels[$i]};
}

for $i (0..$#voiced){
    $unvoiced{$voiced[$i]}=$unvoiced[$i];
    $voiced{$unvoiced[$i]}=$voiced[$i];
}

for $i (0..$#liquids){
    undef $liquid{$liquids[$i]};
}



#print $vowelsre;

sub pronunciation{
    my $str=shift;
    chomp $str;
    #return $str;
    
    # 1. TOWARDS GRAPHEME-PHONEME BIJECTION
        
    # case normalization and punctuation removal

    $str="\L$str";
    $str=~s/[\.\,\?\!\:\;\"\(\)]//go;
    $str=~s/\-/ /go;
    $str=~s/\s+/ /go;
    $str=~s/^ //go;
    $str=~s/ $//go;

    # foreign spelling removal

    $str=~s/e\'//go; # let us pretend it will do for "Liouville'a"
    $str=~s/x/ks/go;
    $str=~s/qu/kv/go;
    $str=~s/q/k/go;
    $str=~s/w/v/go;
    $str=~s/d¾/J/go;
    $str=~s/vindovs/vindows/go;
    $str=~s/ll/l/go;
    ## gymnasium
       $str=~s/asi([ua])/ázi\1/go; 
    ## i + vowel --> ij + vowel (relikvie)
       $str=~s/i([eiíoua])/Tij\1/go;
    ## ismus --> izmus
       $str=~s/ism(\b|u|e|ù)/Tizm\1/go;  ## -ism 
       $str=~s/ism(y\b)/Tizm\1/go;  ##  ne protismysl
    ## kurs../puls.. --> z
       $str=~s/u([lr])s([uùye])/u\1z\2/go; 

       

    
    # false letter combination detection

    # "ou", "au", "eu" as diphtongs

       $str=~s/au/aw/go;
       $str=~s/eu/ew/go; 
       $str=~s/ou/ow/go;

    # equivalent pronunciation removal

       $str=~s/ù/ú/go;
       

    # palatalization treatment

    $str=~s/di/ïi/go;   
    $str=~s/dí/ïí/go;     
##    needed treatment of odinstalovat, odizolovat, ...    
    $str=~s/dì/ïe/go;
    $str=~s/ti/»i/go;
    $str=~s/tí/»í/go;
    $str=~s/tì/»e/go;
    $str=~s/ni/òi/go;
    $str=~s/ní/òí/go;
    $str=~s/nì/òe/go;
    $str=~s/mì/mòe/go;
##  the T character inserted to prevent palatalization of "-tism" etc. deleted    
    $str=~s/T//go;    
    
    # ì - not really palatalization 

    $str=~s/bì/bje/go;
    $str=~s/fì/fje/go;
    $str=~s/pì/pje/go;
    $str=~s/vì/vje/go;
    
    # now y can go

    $str=~s/y/i/go; 
    $str=~s/ý/í/go;      
 
    # kind of phonetic transcription


    $str=~s/ch/x/go;
    $str=~s/\-//go;

    # Now we have the grapheme-phoneme bijection.

    # 2. TOWARDS CONTEXTUAL VARIANTS OF PHONEMES

    # 0-syllable and proclitic word attachment
    
    $str=~s/\b(beze?|pro|do|k|ku|na|s|se|o|ode?|nade?|kromòe|po|s?pod|s?pode?|s?poza|pøi|(z|v)?prostøed?|u|ve?|za|ze?) /\1\-/go;
    
    # glottal stop (z osudí, v atmosféøe)   
    $str=~s/(bez|k|s|od|pod|nad|v|z)\-$vowelsre/\1 \2/go;
    
    $str=~s/\-//go;

    $str=phonetic_assimilations($str);

    return $str;
}

sub phonetic_assimilations{
    # This should be an idempotent procedure
    my $str=shift;

    # "v" treatment: no voiceness assimilation here

    $str=~s/sv/sV/go;
    $str=~s/tv/tV/go;
    $str=~s/kv/kV/go;
    $str=~s/xv/xV/go;
    $str=~s/¹v/¹V/go;
    $str=~s/èv/èV/go;


    # regressive voiceness assimilation and final devoicing

    my @char=split "",$str;
    my $j;
    my $control;
    $control="unvoiced"; # "lód__"
    for $j (reverse 0..$#char){
	if(exists $vowel{$char[$j]}){
	    $control="neutral"; 
	}elsif(exists $liquid{$char[$j]}){
	    $control="neutral"; # "jab_³_ko", "wiód_³_" <-> "plót_³_"
	}elsif($char[$j] eq " "){
	    # $control="unvoiced"; # "stó_g_ brata" <-> "stu_k_ brata"
	                         # "stó_g_ brata" === "stu_k_ brata"
	}elsif($control eq "voiced"){
	    if(defined $voiced{$char[$j]}){
		$char[$j]=$voiced{$char[$j]}; # "pro_¶_ba"
	    }
	}elsif($control eq "unvoiced"){
	    if(defined $unvoiced{$char[$j]}){
		$char[$j]=$unvoiced{$char[$j]}; # "szy_b_ko", "ló_d_" 
	    }
	}elsif($control eq "neutral"){
	    if(defined $unvoiced{$char[$j]}){
		$control="voiced"; # "pro¶_b_a"
	    }elsif(defined $voiced{$char[$j]}){
		$control="unvoiced"; # "szyb_k_o"
	    }
	}
    }
    $str=join "",@char;
   

    # palatalization assimilations

       $str=~s/¹¹/¹/go;
       $str=~s/¾¹/¹/go;

    # devoicing of clusters - a hack
       $str=~s/zc/sc/go;
       
    # voiced V   
       $str=~s/V/v/go;
       $str=~s/J/d¾/go;
       
    return $str;
}

sub vowels_and_clusters{
    ## returns ((C*,V)*,C*)
    my $pronunciation=pronunciation shift;
    $pronunciation=~s/$vowelsre/\(\1\)/go;
    ## r and l as syllable formants
    my $C="[bcèdïfghxkmnòps¹t»vz¾]";
    $pronunciation=~s/($C)(r|l)($C| |$)/\1\(\2\)\3/go;
    ## ou, au, eu as vowels (even more hacking)       
    $pronunciation=~s/\(([aoe])\)w/\(\1w\)/go;
    return $pronunciation;
}

sub stressed_pronunciation{
    my $str=" ".vowels_and_clusters(shift)." ";
    
    ## ! - obligatory stress
    ## ? - hypothetical stress
    ## : - secondary stress
    ## . - unstressed
    $str=~s/\(/:\(/go;
    my @tab=split /:/,$str;
    my $i;
    my @syllable;
    my @stress;
    for $i (0..$#tab){
	if($tab[$i]=~/ /){
	    $syllable[$i]=0;
	}else{
	    $syllable[$i]=$syllable[$i-1]+1;
	}
    }
    for $i (1..$#tab){
	if($syllable[$i]==1){
	    ## obligatory s. at the first syllable
	    $tab[$i]="!".$tab[$i];
	}elsif($syllable[$i-1]==0 and $syllable[$i]==0){ 
		## hypothetical s. at the ultimate syllable for monosyllables
		$tab[$i]="?".$tab[$i];
	}elsif($syllable[$i] % 2 == 1){
		## secondary stress at odd non-initial syllables
		$tab[$i]=":".$tab[$i];
	}else{
		## unstressed
		$tab[$i]=".".$tab[$i];
	}
    }
    $str=join("",@tab);

    $str=~s/^ //go;
    $str=~s/ $//go;
    return $str;
}

sub meter_and_rhyme{ 
    my $verse=stressed_pronunciation(shift);
    ## cut off the suffix starting at the ultimate stress
    $verse=~/([\!\:\?][^\!\?\:]+)$/o; 
    my $rhyme=$1;
    ## suffix is max. 2 syllables
    $rhyme=~s/.*([\!\?\:\.]\([^\(]*\)[^\(]*\([^\(]*\)[^\(]*)/\1/go;
    $rhyme=~s/[\!\?\:\.\(\) ]//go;        
    my $meter=$verse;
    $meter=~s/[^\!\?\:\.]//go;
    return ($meter,$rhyme);
}

sub demo{
    while(<>){
	chomp;
	print "\nCzech pronunciation:\n";
	print "[".pronunciation($_)."]\n";
	print "\nVowels and clusters:\n";
	print "[".vowels_and_clusters($_)."]\n";
	print "\nStressed Czech pronunciation:\n";
	print "[".stressed_pronunciation($_)."]\n";
	print "\nMeter and rhyme:\n";
	my ($rhyme,$meter)=meter_and_rhyme($_);
	print "[$rhyme] [$meter]\n\n";
    }
}


1;
