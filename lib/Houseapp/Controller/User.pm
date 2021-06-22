package Houseapp::Controller::User;

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
        $id = $self->model('User')->_insert_user( $data );
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
        $users = $self->model('User')->_get_list( $data );
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
        $$data{'table'} = 'user';

        $$data{'fieldname'} = 'publish';

        $$data{'value'} = "'t'";

        unless ( $self->model('Utils')->_exists_in_table( 'user', 'id', $$data{'id'} ) ) {
            push @!, "user with '$$data{'id'}' doesn't exist";
        }
        unless ( @! ) {
            $toggle = $self->model('Utils')->_toggle( $data );
            push @!, "Could not toggle User '$$data{'id'}'" unless $toggle;
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
        $$data{'table'} = 'user';

        $$data{'fieldname'} = 'publish';

        $$data{'value'} = "'t'";

        unless ( $self->model('Utils')->_exists_in_table( 'user', 'id', $$data{'id'} ) ) {
            push @!, "user with '$$data{'id'}' doesn't exist";
        }
        unless ( @! ) {
            $toggle = $self->model('Utils')->_toggle( $data );
            push @!, "Could not toggle User '$$data{'id'}'" unless $toggle;
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;