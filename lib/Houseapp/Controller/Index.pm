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

sub login {
    my $self = shift;
warn '=login=';

    my ($data, $resp, $token, $salt, $user, $expires );

    # проверка данных   
    $data = $self->_check_fields();

    if ($$data{'login'} && $$data{'password'}) {
        # получение соли из конфига
        $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];

        # шифрование пароля
        $$data{'password'} = sha256_hex( $$data{'password'}, $salt );

        # проверяем наличие пользователя
        $user = $self->model('User')->_exists_in_users( $$data{'login'}, $$data{'password'} );

        if ( $user ) {
            # делаем token для пользователя
            $token = $$user{'login'} . time() . $$user{'password'};
            $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];
            $token = sha256_hex( $token, $salt );

            # устанавливаем время жизни
            $expires = time() + $$config{'expires'};

            # удаляем пароль из сессии
            delete $$user{'password'};

            # сохраняем токен в глобальном хранилище
            $$tokens{$token} = $user;
            $$tokens{$token}{'expires'} = $expires;
        }
    }
    else {
        push @!, 'Login or password or both are missing';
    }

    $resp->{'data'}->{'profile'} = $user if $user;
    $resp->{'data'}->{'token'} = $token unless @!;
    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';

    @! = ();
    $self->render( json => $resp );
}

# route /logout
# POST or GET поля не передаются (удаляется кука sessions)
sub logout {
    my ($self);
    $self = shift;

warn '=logout=';
    # удаляем сессию, если она есть
    if ( $self->req->headers->header('token') ) {
        delete $$tokens{ $self->req->headers->header('token') };
    }

    $self->render( json => { 'status' => 'ok' } );
}


1;