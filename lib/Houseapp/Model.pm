package Houseapp::Model;

use Mojo::Loader qw(find_modules load_class);
use Mojo::Base -base;

use Carp qw/ croak /;

has modules => sub { {} };

sub new {
    my ($class, %args) = @_;

    my $self = $class->SUPER::new(%args);
    for my $pm ( grep { $_ ne 'Houseapp::Model::Base' } find_modules('Houseapp::Model') ) {
        my $e = load_class( $pm );
        croak "Loading '$pm' failed: $e" if ref $e;
        my ($basename) = $pm =~ /Houseapp::Model::(.*)/;
        $self->modules->{$basename} = $pm->new( %args );
    }

    return $self;
}

sub get_model {
    my ($self, $model) = @_;

    return $self->modules->{$model} || croak "Unknown model '$model'";
}

1;