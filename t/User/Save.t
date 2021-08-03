use Mojo::Base -strict;

use FindBin;
BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

use Test::More;
use Test::Mojo;
use Data::Dumper;

my $t = Test::Mojo->new('Houseapp');

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

# clear_db();

# путь к директории с файлами
my $picture_path = './t/User/files/';

# получение токена для аутентификации
# $t->post_ok( $host.'/auth/login' => form => { 'login' => 'admin', 'password' => 'admin' } );
# unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
#     diag("Can't connect \n");
#     last;
# }
# $t->content_type_is('application/json;charset=UTF-8');
# diag "";
# my $response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
# my $token = $response->{'data'}->{'token'};

# получение id последнего элемента
my $answer = get_last_id_user( $t->app->pg_dbh );

# Ввод данных для редактирования
my $test_data = {
    1 => {
        'data' => {
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'password'    => $t->app->_random_string( 32 ),
            'description' => $t->app->_random_string( 256 ),
            'patronymic' => $t->app->_random_string( 24 ),
            upload => { file => $picture_path . 'all_right.svg' }
        },
        'result' => {
            'id'        => $answer + 1,
            'status'    => 'ok'
        }
    },
    2 => {
        'data' => {
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'password'    => $t->app->_random_string( 32 ),
            'description' => $t->app->_random_string( 256 ),
            upload => { file => $picture_path . 'all_right.svg' }
        },
        'result' => {
            'id'        => $answer + 2,
            'status'    => 'ok'
        }
    }
};
diag "Add users:";

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    # $t->post_ok( $host.'/user/add' => {token => $token} => form => $$test_data{$test}{'data'} );
    $t->post_ok( $host.'/user/add' => form => $$test_data{$test}{'data'} );
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
            'id'        => $answer + 1,
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'password'    => 'admin',
            'newpassword'    => 'newadmin',
            'description' => $t->app->_random_string( 256 ),
            'patronymic' => $t->app->_random_string( 24 ),
            upload => { file => $picture_path . 'all_right.svg' }
        },
        'result' => {
            'status'    => 'ok',
            'id'        => $answer + 1,
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'id'        => $answer + 1,
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'description' => $t->app->_random_string( 256 ),
            upload => { file => $picture_path . 'all_right.svg' }
        },
        'result' => {
            'status'    => 'ok',
            'id'        => $answer + 1,
        },
        'comment' => 'No data:' 
    },
    3 => {
        'data' => {
            'id'        => $answer + 1,
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'password'    => 'admin',
            'newpassword'    => 'newadmin',
            'patronymic' => $t->app->_random_string( 24 ),
        },
        'result' => {
            'status'    => 'ok',
            'id'        => $answer + 1,
        },
        'comment' => 'No doc:' 
    },

    # отрицательные тесты
    4 => {
        'data' => {
            'id'        => 404,
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'password'    => 'admin',
            'newpassword'    => 'newadmin',
            'description' => $t->app->_random_string( 256 ),
            'patronymic' => $t->app->_random_string( 24 ),
            upload => { file => $picture_path . 'all_right.svg' }
        },
        'result' => {
            'message'   => "User with id '404' does not exist",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    5 => {
        'data' => {
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'password'    => 'admin',
            'newpassword'    => 'newadmin',
            'description' => $t->app->_random_string( 256 ),
            'patronymic' => $t->app->_random_string( 24 ),
            upload => { file => $picture_path . 'all_right.svg' }
        },
        'result' => {
            'message'   => "/user/save _check_fields: didn't has required data in 'id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No id:' 
    },
    6 => {
        'data' => {
            'id'        => $answer + 2,
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => 'login',
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'password'    => 'admin',
            'newpassword'    => 'newadmin',
            'description' => $t->app->_random_string( 256 ),
            'patronymic' => $t->app->_random_string( 24 ),
            upload => { file => $picture_path . 'all_right.svg' }
        },
        'result' => {
            'message'   => "login 'login' already used",
            'status'    => 'fail'
        },
        'comment' => 'Login already used:' 
    },
    7 => {
        'data' => {
            'id'        => $answer + 2,
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'password'    => 'admin',
            'newpassword'    => 'admin',
            'description' => $t->app->_random_string( 256 ),
            'patronymic' => $t->app->_random_string( 24 ),
            upload => { file => $picture_path . 'all_right.svg' }
        },
        'result' => {
            'message'   => "Password and newpassword are the same",
            'status'    => 'fail'
        },
        'comment' => 'Same password:' 
    },
    8 => {
        'data' => {
            'id'        => $answer + 2,
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'newpassword'    => 'admin',
            'description' => $t->app->_random_string( 256 ),
            'patronymic' => $t->app->_random_string( 24 ),
            upload => { file => $picture_path . 'all_right.svg' }
        },
        'result' => {
            'message'   => "Empty password",
            'status'    => 'fail'
        },
        'comment' => 'No password:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    diag ( $$test_data{$test}{'comment'} );
    # $t->post_ok($host.'/user/save' => {token => $token} => form => $data )
    $t->post_ok($host.'/user/save' => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
    diag "";
};

done_testing();

# очистка тестовой таблицы
# sub clear_db {
#     if ($t->app->config->{test}) {
#         $t->app->pg_dbh->do('ALTER SEQUENCE "public".users_id_seq RESTART');
#         $t->app->pg_dbh->do('TRUNCATE TABLE "public".users RESTART IDENTITY CASCADE');
#     }
#     else {
#         warn("Turn on 'test' option in config")
#     }
# }

# получение id последнего пользователя
# my $answer = get_last_id_user( $connect );
sub get_last_id_user {
    my $connect = shift;

    my $sth = $connect->prepare( 'SELECT max("id") AS "id" FROM "public"."users"' );
    $sth->execute();
    my $answer = $sth->fetchrow_hashref();

    return $$answer{'id'};
}