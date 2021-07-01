use Mojo::Base -strict;

use FindBin;
BEGIN {
    unshift @INC, "$FindBin::Bin/../lib";
}

use Test::More;
use Test::Mojo;
use Data::Dumper;

my $t = Test::Mojo->new('Houseapp');

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

clear_db();

# получение токена для аутентификации
$t->post_ok( $host.'/auth/login' => form => { 'login' => 'admin', 'password' => 'admin' } );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";
my $response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
my $token = $response->{'data'}->{'token'};


# Ввод данных для вывода
my $test_data = {
    1 => {
        'data' => {
            'login'      => 'login',
            'email'     => 'email',
            'phone'    => 'phone',
            'password'    => 'password'
        },
        'result' => {
            'id'        => '1',
            'status'    => 'ok'
        }
    },
    2 => {
        'data' => {
            'login2'      => 'login2',
            'email2'     => 'email2',
            'phone2'    => 'phone2',
            'password2'    => 'password2'
        },
        'result' => {
            'id'        => '2',
            'status'    => 'ok' 
        }
    }
};
diag "Create groups:";
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $t->post_ok( $host.'/user_data/add' => {token => $token} => form => $$test_data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$test_data{$test}{'result'} );
}
diag "";

# Проверка ввода в Groups
my $result = {
    'list' => [
        {
            'login'      => 'login',
            'email'     => 'email',
            'phone'    => 'phone',
            'password'    => 'password'
        },
        {
            'login2'      => 'login2',
            'email2'     => 'email2',
            'phone2'    => 'phone2',
            'password2'    => 'password2'
        }
    ],
    'status' => 'ok'
};

diag "All groups:";
$t->post_ok( $host.'/user_data/' => {token => $token} )
    ->status_is(200)
    ->content_type_is('application/json;charset=UTF-8')
    ->json_is( $result );
diag "";

done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".user_datas_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".user_datas RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}


