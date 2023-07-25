package Speak::Polish;

##
## author: £ukasz Dêbowski, 2003
##
## e-mail: ldebowsk@ipipan.waw.pl
##

## This package provides for Polish phonetic transcription and rhyme detection

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

our @vowels=qw(a ± e ê y o u);
our @obstruents
    =qw(
	p b
	f v
	t d
	s z
	¶ ¼
	¹ ¾
	k g
	x h
	);
our @liquids=qw(m n ñ r l j w);

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
    $str=~s/qu/kw/go;
    $str=~s/q/k/go;
    $str=~s/v/w/go;

    # false letter combination detection

    $str=~s/(n|z)au/\1a-u/go;
    $str=~s/eu(s|sz)/e-u\1/go;
    # merges "nautyczny", "zauro-" <-> "nauka", "zau³ek"
    # merges "marzn±æ","obmierz³y" <-> "marzyæ", "obmierzaæ"
    # merges "zi¶ciæ" <-> "zima"

    # "au", "eu" removal

    $str=~s/au/a³/go;
    $str=~s/eu/e³/go;

    # equivalent pronunciation removal

    $str=~s/ch/h/go;
    $str=~s/ó/u/go;
    # "rz" will be dealt later on

    # archaic long "e" treatment

    $str=~s/lé/li/go;
    $str=~s/ié/i/go;
    $str=~s/é/y/go;

    # palatalization treatment

    $str=~s/ia/\'a/go;
    $str=~s/i±/\'±/go;
    $str=~s/ie/\'e/go;
    $str=~s/iê/\'ê/go;
    $str=~s/io/\'o/go;
    $str=~s/iu/\'u/go;
    $str=~s/ii/\'y/go; # merges "-lii", "-nii" <-> "-li", "-ni"
    $str=~s/i/\'y/go;
    $str=~s/s\'/¶/go;
    $str=~s/z\'/¼/go;
    $str=~s/c\'/æ/go;
    $str=~s/n\'/ñ/go;
    $str=~s/\'/j/go;
 
    # kind of phonetic transcription

    $str=~s/c/ts/go;
    $str=~s/æ/t¶/go;
    $str=~s/sz/¹/go;
    $str=~s/¿/¾/go;
    $str=~s/w/v/go;
    $str=~s/³/w/go;
    $str=~s/h/x/go;
    $str=~s/rz/ø/go; # merges "rzeka" <-> "marzn±æ"

    $str=~s/\-//go;

    # Now we have the grapheme-phoneme bijection.

    # 2. TOWARDS CONTEXTUAL VARIANTS OF PHONEMES

    # 0-syllable and proclitic word attachment

    $str=~s/\b(a|jy|¾e) /\1\-/go;
    $str=~s/\b(beze?|dla|do|ku|na|(s?po|z)?nade?|ñe|o|ode?|o?prut¹|po|s?pode?|s?poza|s?pøede?|(po)?pøeze?|pøy|(s?(po)|v)?¶rude?|u|ve?|za|ze?) /\1\-/go;
    $str=~s/\-//go;

    $str=phonetic_assimilations($str);

    return $str;
}

sub phonetic_assimilations{
    # This should be an idempotent procedure
    my $str=shift;

    # "w" treatment 

    $str=~s/pv/pf/go;
    $str=~s/fv/ff/go;
    $str=~s/tv/tf/go;
    $str=~s/sv/sf/go;
    $str=~s/¶v/¶f/go;
    $str=~s/¹v/¹f/go;
    $str=~s/kv/kf/go;
    $str=~s/hv/hf/go;

    $str=~s/prv/prf/go;
    $str=~s/trv/trf/go;
    $str=~s/krv/krf/go;

    # "rz" treatment

    $str=~s/pø/p¹/go;
    $str=~s/fø/f¹/go;
    $str=~s/tø/t¹/go;
    $str=~s/sø/s¹/go;
    $str=~s/¶ø/¶¹/go;
    $str=~s/¹ø/¹¹/go;
    $str=~s/kø/k¹/go;
    $str=~s/hø/h¹/go;

    $str=~s/ø/¾/go; 

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
   
    # denasalizations

    $str=~s/±([pbtdkgl³])/oN\1/go;
    $str=~s/ê([pbtdkgl³])/eN\1/go;
    $str=~s/N([pb])/m\1/go;
    $str=~s/N([tdkg])/n\1/go;
    $str=~s/N([l³])/\1/go;

    $str=~s/ê\b/e/go; # merges "piszê" <-> "pisze"
    
    # palatalization assimilations

    $str=~s/¹¶/¶¶/go;
    $str=~s/¾¼/¼¼/go;
    $str=~s/st¶/¶t¶/go;
    $str=~s/zd¼/¼d¼/go;
    $str=~s/n(t¶|d¼)/ñ\1/go;

    return $str;
}

sub vowels_and_clusters{
    ## returns ((C*,V)*,C*)
    my $pronunciation=pronunciation shift;
    $pronunciation=~s/$vowelsre/\(\1\)/go;
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
    my @lastbut;
    my @stress;
    for $i (reverse 0..$#tab){
	if($tab[$i]=~/ /){
	    $lastbut[$i]=0;
	}else{
	    $lastbut[$i]=$lastbut[$i+1]+1;
	}
    }
    for $i (reverse 1..$#tab){
	if($lastbut[$i]==1){
	    ## obligatory s. at the penultimate syllable
	    $tab[$i]="!".$tab[$i]; 
	}elsif($lastbut[$i-1]==0){ 
	    if($lastbut[$i]==0){
		## hypothetical s. at the ultimate syllable for monosyllables
		$tab[$i]="?".$tab[$i];
	    }elsif(($lastbut[$i]>2)&&(($i<2)||$lastbut[$i-2]==1)){
		## secondary s. at the first syllable
		$tab[$i]=":".$tab[$i];
	    }else{
		## unstressed
		$tab[$i]=".".$tab[$i];
	    }
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
    $verse=~/([\!\?\:][^\!\?\:]+)$/o;
    my $rhyme=$1;
    $rhyme=~s/[\!\?\:\.\(\) ]//go;
    my $meter=$verse;
    $meter=~s/[^\!\?\:\.]//go;
    return ($meter,$rhyme);
}

sub demo{
    while(<>){
	chomp;
	print "\nPolish pronunciation:\n";
	print "[".pronunciation($_)."]\n";
	print "\nVowels and clusters:\n";
	print "[".vowels_and_clusters($_)."]\n";
	print "\nStressed Polish pronunciation:\n";
	print "[".stressed_pronunciation($_)."]\n";
	print "\nMeter and rhyme:\n";
	my ($rhyme,$meter)=meter_and_rhyme($_);
	print "[$rhyme] [$meter]\n\n";
    }
}


1;
