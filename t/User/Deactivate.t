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
$t->post_ok( $host.'/auth/login' =>  form => { 'login' => 'admin', 'password' => 'admin' } );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";
my $response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
my $token = $response->{'data'}->{'token'};


# Импорт доступных групп
diag "Add group:";
my $data = {
    'name'      => 'test',
    'surname'     => 'test',
    'status'    => 1
};
$t->post_ok( $host.'/user/add' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'        => 1
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 1
        },
        'comment' => 'All right:' 
    },

    # отрицательные тесты
    2 => {
        'data' => {
        },
        'result' => {
            'message'   => "/user/deactivate _check_fields: didn't has required data in 'id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No id:' 
    },
    3 => {
        'data' => {
            'id'        => 404
        },
        'result' => {
            'message'   => "Id '404' doesn't exist",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    4 => {
        'data' => {
            'id'        => 0
        },
        'result' => {
            'message'   => "Id '0' doesn't exist",
            'status'    => 'fail'
        },
        'comment' => '0 id:' 
    },
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    $t->post_ok($host.'/user/deactivate' => {token => $token} => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
    diag "";
};

done_testing();

# очистка тестовой таблицы
sub clear_db {
    if ($t->app->config->{test}) {
        $t->app->pg_dbh->do('ALTER SEQUENCE "public".users_id_seq RESTART');
        $t->app->pg_dbh->do('TRUNCATE TABLE "public".users RESTART IDENTITY CASCADE');
    }
    else {
        warn("Turn on 'test' option in config")
    }
}