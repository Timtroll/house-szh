use Mojo::Base -strict;

use FindBin;
BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

use Test::More;
use Test::Mojo;
use Mojo::JSON qw( decode_json );
use Digest::SHA qw( sha256_hex );
use Data::Dumper;

my $t = Test::Mojo->new('Houseapp');

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

clear_db();

# путь к директории с файлами
my $picture_path = './t/User/files/';

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
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'password'    => 'admin',
            'description' => $t->app->_random_string( 256 ),
            'patronymic' => $t->app->_random_string( 24 ),
            upload => { file => $picture_path . 'all_right_save1.svg' }
        }
    },
    2 => {
        'data' => {
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'password'    => 'admin',
            'description' => $t->app->_random_string( 256 ),
            upload => { file => $picture_path . 'all_right_save2.svg' }
        }
    }
};
diag "Add users:";

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $t->post_ok( $host.'/user/add' => {token => $token} => form => $$test_data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    diag "";
}

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'        => 2,
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
            upload => { file => $picture_path . 'all_right_save1.svg' }
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 2,
        },
        'comment' => 'All fields:' 
    },
    2 => {
        'data' => {
            'id'        => 2,
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'description' => $t->app->_random_string( 256 ),
            upload => { file => $picture_path . 'all_right_save1.svg' }
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 2,
        },
        'comment' => 'No data:' 
    },
    3 => {
        'data' => {
            'id'        => 2,
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => 'newlogin',
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'password'    => 'newadmin',
            'newpassword'    => 'admin',
            'patronymic' => $t->app->_random_string( 24 ),
        },
        'result' => {
            'status'    => 'ok',
            'id'        => 2,
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
            'id'        => 3,
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => 'newlogin',
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'password'    => 'admin',
            'newpassword'    => 'newadmin',
            'description' => $t->app->_random_string( 256 ),
            'patronymic' => $t->app->_random_string( 24 ),
            upload => { file => $picture_path . 'all_right.svg' }
        },
        'result' => {
            'message'   => "login 'newlogin' already used",
            'status'    => 'fail'
        },
        'comment' => 'Login already used:' 
    },
    7 => {
        'data' => {
            'id'        => 3,
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
            'id'        => 3,
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
    },
    9 => {
        'data' => {
            'id'        => 3,
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
            upload => { file => $picture_path . 'all_right_save1.svg' }
        },
        'result' => {
            'message'   => "file with this name already used",
            'status'    => 'fail'
        },
        'comment' => 'Same filename:' 
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

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'        => 2
        },
        'result' => {
            'id'        => 2,
            'status'    => 'ok'
        },
        'comment' => 'All right:' 
    },
    2 => {
        'data' => {
            'id'        => 3
        },
        'result' => {
            'id'        => 3,
            'status'    => 'ok'
        },
        'comment' => 'All right:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    $t->get_ok($host.'/user/delete' => {token => $token} => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
    diag "";
};

clear_db();

done_testing();

# очистка тестовой таблицы
sub clear_db {
    # получение соли из конфига
    my $salt = $t->app->config->{'secrets'}->[0];

    # преобразование пароля
    my $password = sha256_hex( 'admin', $salt );

    $t->app->pg_dbh->do('ALTER SEQUENCE "public".users_id_seq RESTART');
    $t->app->pg_dbh->do('TRUNCATE TABLE "public".users RESTART IDENTITY CASCADE');

    $t->app->pg_dbh->do('ALTER SEQUENCE "public".data_id_seq RESTART');
    $t->app->pg_dbh->do('TRUNCATE TABLE "public".user_data RESTART IDENTITY CASCADE');

    $t->app->pg_dbh->do('ALTER SEQUENCE "public".doc_id_seq RESTART');
    $t->app->pg_dbh->do('TRUNCATE TABLE "public".user_doc RESTART IDENTITY CASCADE');

    $t->app->pg_dbh->do('TRUNCATE TABLE "public".user_links RESTART IDENTITY CASCADE');

    $t->app->pg_dbh->do('INSERT INTO "public"."users" ( "login", "email", "status", "password" ) VALUES ( \'admin\', \'admin@admin\', \'1\', \''. $password .' \')');
}

# получение id последнего пользователя
# my $answer = get_last_id_user( $connect );
sub get_last_id_user {
    my $connect = shift;

    my $sth = $connect->prepare( 'SELECT max("id") AS "id" FROM "public"."users"' );
    $sth->execute();
    my $answer = $sth->fetchrow_hashref();

    return $$answer{'id'};
}