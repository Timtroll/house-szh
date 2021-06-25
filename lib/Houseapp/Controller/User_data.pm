package Houseapp::Controller::User_data;

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
        $id = $self->model('User_data')->_insert_data( $data );
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
        $users = $self->model('User_data')->_get_list( $data );
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
        $$data{'table'} = 'user_data';

        unless ( $self->model('Utils')->_exists_in_table( 'user_data', 'id', $$data{'id'} ) ) {
            push @!, "user with '$$data{'id'}' doesn't exist";
        }
        unless ( @! ) {
            $toggle = $self->model('Utils')->_activate( $data );
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
        $$data{'table'} = 'user_data';

        unless ( $self->model('Utils')->_exists_in_table( 'user_data', 'id', $$data{'id'} ) ) {
            push @!, "user with '$$data{'id'}' doesn't exist";
        }
        unless ( @! ) {
            $toggle = $self->model('Utils')->_deactivate( $data );
            push @!, "Could not toggle Data '$$data{'id'}'" unless $toggle;
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub delete {
    my $self = shift;

    my ( $toggle, $resp, $data );

    # проверка данных
    $data = $self->_check_fields();

    # проверка существования элемента для изменения
    unless ( @! ) {
        $$data{'table'} = 'user_data';

        unless ( $self->model('Utils')->_exists_in_table( 'user_data', 'id', $$data{'id'} ) ) {
            push @!, "user with '$$data{'id'}' doesn't exist";
        }
        unless ( @! ) {
            $toggle = $self->model('Utils')->_delete( $data );
            push @!, "Could not toggle Data '$$data{'id'}'" unless $toggle;
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub edit {
    my $self = shift;

    my ( $result, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        unless ( $self->model('Utils')->_exists_in_table('user_data', 'id', $$data{'id'} ) ) {
            push @!, "Could not get Data '$$data{'id'}'";
        }
    }

    unless ( @! ) {
        $result = $self->model('User_data')->_get_data( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub save {
    my ( $self ) = shift;

    my ( $id, $parent, $data, $resp );


    # проверка данных
    $data = $self->_check_fields();

    # проверка существования обновляемой строки
    unless ( @! ) {
        unless ( $self->model('Utils')->_exists_in_table('user_data', 'id', $$data{'id'}) ) {
            push @!, "Data with id '$$data{'id'}' does not exist";
        }
    }

    unless ( @! ) {
        $id = $self->model('User_data')->_update_data( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;