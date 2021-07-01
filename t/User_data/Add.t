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

my $test_data = {
    # положительные тесты
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
        },
        'comment' => 'All fields:'
    },
    2 => {
        'data' => {
            'login'      => 'login2',
            'email'     => 'email2',
            'phone'    => 'phone2',
            'password'    => 'password2'
        },
        'result' => {
            'id'        => '2',
            'status'    => 'ok',
        },
        'comment' => 'status zero:'
    },

    # отрицательные тесты
    3 => {
        'data' => {
            'login'      => 'login 3',
            'email'     => 'email3',
            'phone'    => 'phone3',
            'password'    => 'password3'
        },
        'result' => {
            'message'   => "/user_data/add _check_fields: empty field 'name', didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong input format:'
    },
    4 => {
        'data' => {
            'login'      => 'login',
            'email'     => 'email3',
            'phone'    => 'phone3',
            'password'    => 'password3'
        },
        'result' => {
            'message'    => "login 'login' already exists",
            'status'     => 'fail'
        },
        'comment' => 'Same name:'
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/user_data/add' => {token => $token}  => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );
    diag "";
};
clear_db();

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

