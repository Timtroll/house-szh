package Houseapp::Controller::Data;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use common;
use Data::Dumper;

sub add {
    my $self = shift;

    my ( $id, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        $id = $self->model('Data')->_insert_data( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub index {
    my $self = shift;

    my ( $data, $list, $resp, $users );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        $$data{'page'} = 1 unless $$data{'page'};
        $$data{'limit'}  = $settings->{'per_page'};
        $$data{'offset'} = ( $$data{'page'} - 1 ) * $$data{'limit'};

        # получаем список пользователей группы
        $users = $self->model('Data')->_get_list( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'list'} = $list unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub activate {
    my $self = shift;

    my ( $toggle, $resp, $data );

    # проверка данных
    $data = $self->_check_fields();

    # проверка существования элемента для изменения
    unless ( @! ) {
        $$data{'table'} = 'data';

        $$data{'fieldname'} = 'publish';

        $$data{'value'} = "'t'";

        unless ( $self->model('Utils')->_exists_in_table( 'data', 'id', $$data{'id'} ) ) {
            push @!, "user with '$$data{'id'}' doesn't exist";
        }
        unless ( @! ) {
            $toggle = $self->model('Utils')->_toggle( $data );
            push @!, "Could not toggle Data '$$data{'id'}'" unless $toggle;
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub deactivate {
    my $self = shift;

    my ( $toggle, $resp, $data );

    # проверка данных
    $data = $self->_check_fields();

    # проверка существования элемента для изменения
    unless ( @! ) {
        $$data{'table'} = 'data';

        $$data{'fieldname'} = 'publish';

        $$data{'value'} = "'t'";

        unless ( $self->model('Utils')->_exists_in_table( 'data', 'id', $$data{'id'} ) ) {
            push @!, "user with '$$data{'id'}' doesn't exist";
        }
        unless ( @! ) {
            $toggle = $self->model('Utils')->_toggle( $data );
            push @!, "Could not toggle Data '$$data{'id'}'" unless $toggle;
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;