use strict;
use warnings;
package LaTeX::ToUnicode;
#ABSTRACT: Convert LaTeX commands to Unicode

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw( convert );

use utf8;
use LaTeX::ToUnicode::Tables;

=method convert( $string, %options )

=cut

sub convert {
    my ( $string, %options ) = @_;
    $string = _convert_commands( $string );
    $string = _convert_accents( $string );
    $string = _convert_german( $string ) if $options{german};
    $string = _convert_symbols( $string );
    $string = _convert_specials( $string );
    $string = _convert_markups( $string );
    $string =~ s/{(\w*)}/$1/g;
    $string;
}

sub _convert_accents {
    my $string = shift;
    $string =~ s/({\\(.){(\w{1,2})}})/$LaTeX::ToUnicode::Tables::ACCENTS{$2}{$3} || $1/eg; # {\"{a}}
    $string =~ s/({\\(.)(\w{1,2})})/$LaTeX::ToUnicode::Tables::ACCENTS{$2}{$3} || $1/eg; # {\"a}
    $string;
}

sub _convert_specials {
    my $string = shift;
    my $specials = join( '|', @LaTeX::ToUnicode::Tables::SPECIALS );
    my $pattern = qr/\\($specials)/o;
    $string =~ s/$pattern/$1/g;
    $string =~ s/\\\$/\$/g;
    $string;
}

sub _convert_commands {
    my $string = shift;

    foreach my $command ( keys %LaTeX::ToUnicode::Tables::COMMANDS ) {
        $string =~ s/{\\$command}/$LaTeX::ToUnicode::Tables::COMMANDS{$command}/g;
        $string =~ s/\\$command(?=\s|\b)/$LaTeX::ToUnicode::Tables::COMMANDS{$command}/g;
    }

    $string;
}

sub _convert_german {
    my $string = shift;

    foreach my $symbol ( keys %LaTeX::ToUnicode::Tables::GERMAN ) {
        $string =~ s/\Q$symbol\E/$LaTeX::ToUnicode::Tables::GERMAN{$symbol}/g;
    }
    $string;
}

sub _convert_symbols {
    my $string = shift;

    foreach my $symbol ( keys %LaTeX::ToUnicode::Tables::SYMBOLS ) {
        $string =~ s/{\\$symbol}/$LaTeX::ToUnicode::Tables::SYMBOLS{$symbol}/g;
        $string =~ s/\\$symbol/$LaTeX::ToUnicode::Tables::SYMBOLS{$symbol}/g;
    }
    $string;
}

sub _convert_markups {
    my $string = shift;

    my $markups = join( '|', @LaTeX::ToUnicode::Tables::MARKUPS );
    $string =~ s/({[^{}]+)\\(?:$markups)\s+([^{}]+})/$1$2/g; # { ... \command ... }
    my $pattern = qr/{\\(?:$markups)\s+([^{}]*)}/o;
    $string =~ s/$pattern/$1/g;

    $string =~ s/``/“/g;
    $string =~ s/`/”/g;
    $string =~ s/''/‘/g;
    $string =~ s/'/’/g;
    $string;
}

1;
