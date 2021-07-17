package common;

use utf8;
use warnings;
use strict;

use Mojo::Home;
use Mojo::JSON qw(decode_json);

# binmode(STDIN, ":utf8");
# binmode(STDOUT, ":utf8");
# binmode(STDERR, ":utf8");

use Exporter();
use vars qw(
    @ISA
    @EXPORT
    @EXPORT_OK
    $config
    $log
    $vfields
    $tokens
);

use Data::Dumper;

my $config  = {};
my $log     = {};
my $vfields = {};
our $base    = [];
our $cache    = [];
our $cache_id   = {};
our $cache_name   = {};
our $queue   = {};
our $tokens   = {};

@ISA = qw( Exporter );
@EXPORT = qw(
    &rel_file
    &read_file
    &write_file
    $config
    $log
    $vfields
    $tokens
);
@EXPORT_OK = qw(
    &rel_file
    &read_file
    &write_file
    $config
    $log
    $vfields
    $tokens
);

# Find and manage the project root directory
my $home = Mojo::Home->new;
$home->detect;

sub rel_file { $home->rel_file(shift); }
# саба для макс id
sub read_file {
    my ( $path, $utf ) = shift;

    # my $data < io $path;
    my $data;
    open ( FILE, '<', $path ) or push @!, "Can't open file $path";
        if ( $utf ) {
            binmode(FILE, ":encoding(UTF-8)");
        }
        while ( <FILE> ) {
            $data .= $_;
        }
    close ( FILE );

    return $data;
}

sub write_file {
    my ( $path, $option, $data ) = @_;

    # my $data < io $path;
    open ( FILE, '>', $path ) or push @!, "Can't open file $path";
        if ( $option ) {
            binmode(FILE, ":encoding(UTF-8)");
        }
        print FILE $data;
    close ( FILE );

    return @! ? undef : 1;
}

1;
