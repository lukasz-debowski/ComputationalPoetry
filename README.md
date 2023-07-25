
# Phonetic transcription and computational poetry

In this repository, the following directories are provided:

    Speak — two Perl modules (libraries) that provide approximate
    phonetic transcription of Polish and Czech,
    
    TURPIS — a Perl script that generates rhymed and rhythmical but
    mostly syntactically incorrect verses,
    
    Michał Rudolf's Poeta — a Perl script that generates rhymeless but
    syntactically correct verses.

## Speak

These Perl modules define procedures for transcribing texts in Polish
and Czech phonetically (in some good approximation). The package was
intented as a library for TURPIS — a generator of rhymed poems in
these languages. The quality of the phonetic transcription is intended
to be good enough for meter and rhyme equivalence but it is far from
being accurate for speech synthesis and recognition.

The directory Speak/ contains the following files:

    {Polish,Czech}.pm — the modules,
    
    speak_demo.pl — an executable demo.

I am the author of the phonetic rules for Polish, whereas an
adaptation of these rules for Czech was done by Alexandr Rosen. If you
write a compatible module for another language and ask me to publish
it here, I will certainly agree.

EXAMPLE:

Już konie w stajnię wzięto, już im hojnie dano.

Polish pronunciation:
[juš końe fstajńe vźento juž jym xojńe dano]

Vowels and clusters:
[j(u)š k(o)ń(e) fst(a)jń(e) vź(e)nt(o) j(u)ž j(y)m x(o)jń(e) d(a)n(o)]

Stressed Polish pronunciation:
[j?(u)š k!(o)ń.(e) fst!(a)jń.(e) vź!(e)nt.(o) j?(u)ž j?(y)m x!(o)jń.(e) d!(a)n.(o)]

Meter and rhyme:
[?!.!.!.??!.!.] [ano]

## TURPIS (The Ultimate Retriever of Poetry Ignoring Sense)

TURPIS is a generator of random poems originally intended for
Polish. It generates rhymed and rhythmical poetry according to several
predefined patterns of versification (limmerick, saphic stanza,
sonnet, trzynastozgłoskowiec, haiku etc.). Thanks to a contribution by
Alexandr Rosen, TURPIS can versify in Czech as well.

TURPIS does not write from a scratch. It needs some training data,
namely a sufficiently large file (>100KB) containing plain text in a
given language. The text is read in order to excerpt all continuous
substrings which match the predefined types of verse lines. The
excerpted substrings are stored in a database indexed by the
substring's meter, rhyme and last word. For composing the poems, the
substrings are retrieved at random to form the consecutive lines of a
poem. Since the text excerption takes some time, one can save the
database of excerpted substrings and open it during the next session
of TURPIS instead of excerpting the same text again.

A more detailed description of the program and several examples of its
poetry in Polish may be found in my presentation at ROJN seminar
(rojn2003.pdf). Czech examples are presented in Alexandr Rosen's
contribution to the festschrift for Vladimír Petkevič (rosen.pdf).

The directory Turpis/ contains the following files:

    turpis.pl — TURPIS 0.5 itself,
    
    turpis_theory_default — the default poetic theory,
    
    turpis_theory_rosen — the poetic theory extended by A. Rosen,
    
    pt_I.txt — "Gospodarstwo", the first chapter of "Pan Tadeusz" by
    Adam Mickiewicz (an example text to extract),
    
    turpis_base_pt_I — the database of verse lines excerpted from
    "Gospodarstwo",

    sortrhymes.pl — a script which reads trzynastozgłoskowiec (the
    13-syllable meter of "Pan Tadeusz") and outputs the sorted list of
    rhymes, their frequencies, and the verses having a wrong meter; an
    example call:

    sortrhymes.pl <pt_I.txt >pt_I_rymy.txt

## Michał Rudolf's Poeta

It is a very popular pastime to compose probabilistic grammars (PCFGs)
for generating grammatically correct but funnily nonsensical texts. By
no means it is an entertainment of our times. In the communist
countries, numerous PCFGs were devised on paper to model the official
newspeak. Times changed, technology progressed, and nowadays some
nonsense gets accepted for scientific conferences, cf. SCIgen's paper
on "Rooter".

A brilliant contribution to the PCFG text generation was done by dr
Michał Rudolf in the subdomain of rhymeless and deeply profound Polish
poetry. I got his permission to publish his PCFG here.

The directory Poeta/ contains the following files:

    poeta.pl — the executable file (written anew by me),

    reguly.txt — the PCFG file written originally by Michał Rudolf.

Just a poem:

     ogień śpi jak kałuża nicości
     kiedy wino czeka na krzyk

     sprawiedliwa fala rozmyła się w rozpaczy
     płaskie serce nieba nie wróci
     
     to ten kto pożąda ziemi

