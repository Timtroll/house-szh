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


# Ввод данных для редактирования
my $test_data = {
    1 => {
        'data' => {
            'name'      => 'name1',
            'surname'     => 'surname1',
            'status'    => 1
        },
        'result' => {
            'id'        => '1',
            'status'    => 'ok'
        }
    },
    2 => {
        'data' => {
            'name'      => 'name2',
            'surname'     => 'surname2',
            'status'    => 1
        },
        'result' => {
            'id'        => '2',
            'status'    => 'ok' 
        }
    }
};
diag "Add groups:";
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $t->post_ok( $host.'/user/add' => {token => $token} => form => $$test_data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$test_data{$test}{'result'} );
    diag "";
}

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'        => 1,
            'name'      => 'name',
            'surname'     => 'surname',
            'status'    => 1
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 1,
        },
        'comment' => 'All fields:' 
    },

    # отрицательные тесты
    2 => {
        'data' => {
            'id'        => 404,
            'name'      => 'name3',
            'surname'     => 'surname3',
            'status'    => 1
        },
        'result' => {
            'message'   => "User with id '404' does not exist",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    3 => {
        'data' => {
            'name'      => 'name',
            'surname'     => 'surname',
            'status'    => 1
        },
        'result' => {
            'message'   => "/user/save _check_fields: didn't has required data in 'id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No id:' 
    },
    4 => {
        'data' => {
            'id'        => 1,
            'surname'     => 'surname',
            'status'    => 1
        },
        'result' => {
            'message'   => "/user/save _check_fields: didn't has required data in 'name' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No name:' 
    },
    5 => {
        'data' => {
            'id'        => 1,
            'name'      => 'name',
            'status'    => 1
        },
        'result' => {
            'message'   => "/user/save _check_fields: didn't has required data in 'surname' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No surname:' 
    },
    6 => {
        'data' => {
            'id'        => 1,
            'name'      => 'name',
            'surname'     => 'surname'
        },
        'result' => {
            'message'   => "/user/save _check_fields: didn't has required data in 'status' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No value:' 
    },
    7 => {
        'data' => {
            'id'        => 1,
            'name'      => 'name*',
            'surname'     => 'surname',
            'status'    => 1
        },
        'result' => {
            'message'   => "/user/save _check_fields: empty field 'name', didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong field type:' 
    },
    8 => {
        'data' => {
            'id'        => 1,
            'surname'     => 'surname2',
            'name'      => 'name8',            
            'status'    => 0
        },
        'result' => {
            'message'   => "User with surname 'surname2' already exists",
            'status'    => 'fail'
        },
        'comment' => 'surname already used:' 
    },
    9 => {
        'data' => {
            'id'        => 1,
            'surname'     => 'surname9',
            'name'      => 'name2',            
            'status'    => 0
        },
        'result' => {
            'message'   => "User with name 'name2' already exists",
            'status'    => 'fail'
        },
        'comment' => 'Name already used:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    diag ( $$test_data{$test}{'comment'} );
    $t->post_ok($host.'/user/save' => {token => $token} => form => $data )
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