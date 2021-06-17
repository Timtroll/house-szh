package Houseapp::Controller::Index;

use utf8;
use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';
use common;

use Data::Dumper;

sub index {
    my $self = shift;
warn 'index';

    $self->render(
        'template'    => 'index',
        'title'       => 'Описание роутов'
    );

}

sub error {
    my $self = shift;
warn 'error';

    $self->render( 'json' => { 'status' => 'fail', 'message' => $self->param('message') }, status => 666 );
}

sub load {
    my $self = shift;

    my ( $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    # чистим кэш
    $cache = [];
    $cache_id = {};
    $cache_name = {};

    $self->model('Basis')->_recursive_get( $$data{'id'} );

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 0 : 1;
    $resp->{'data'} = $cache_id unless @!;

    @! = ();

    $self->render( 'json' => $cache );
}

sub get_cache {
    my $self = shift;

    $self->render( 'json' => $cache_id );
}

sub get_base {
    my $self = shift;

    $self->render( 'json' => $base );
}

sub set {
    my $self = shift;

    my ( $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless( @! ) {
        if ( $self->model('Basis')->_exist_item( $cache_name, $$data{'name'} ) ) {
            push @!, "name '$$data{'name'}' already used";
        }
    }

    unless( @! ) {
        if ( $$data{'id'} ) {
            unless ( $self->model('Basis')->_exist_item( $cache_id, $$data{'id'} ) ) {
                push @!, "Could not find field '$$data{'id'}'";
            }
            else {
                $self->model('Basis')->_update_element();
                unshift @$queue, {'command' => 'update', 'id' => $$data{'id'} };                
            }
        }
        else {
            unless ( $self->model('Basis')->_exist_item( $cache_id, $$data{'parent'} ) ) {
                push @!, "Could not find field '$$data{'parent'}'";
            }
            else {
                $self->model('Basis')->_insert_element();
                unshift @$queue, {'command' => 'add', 'id' => $$data{ $max_cache_id } };
            }
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 0 : 1;
    $resp->{'id'} = 1 unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}


1;