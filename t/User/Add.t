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

my ( $t, $host, $picture_path, $test_data, $extension, $regular, $file_path, $desc_path, $cmd, $data, $result, $response, $token, $url, $size, $description );
$t = Test::Mojo->new('Houseapp');

# Устанавливаем адрес
$host = $t->app->config->{'host'};
clear_db();

# путь к директории с файлами 
$picture_path = './t/User/files/';

# получение токена для аутентификации
$t->post_ok( $host.'/auth/login' => form => { 'login' => 'admin', 'password' => 'admin' } );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect \n");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";
$response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
$token = $response->{'data'}->{'token'};

# получение id последнего элемента
my $answer = get_last_id_user( $t->app->pg_dbh );

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => 'temp',
            'email'     => 'temp',
            'phone'    => '7(921)1111111',
            'password'    => $t->app->_random_string( 32 ),
            'description' => $t->app->_random_string( 256 ),
            'patronymic' => $t->app->_random_string( 24 ),
            upload => { file => $picture_path . 'all_right1.svg' }
        },
        'result' => {
            'id'        => $answer + 1,
            'status'    => 'ok'
        },
        'comment' => 'All fields:'
    },
    2 => {
        'data' => {
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'password'    => $t->app->_random_string( 32 ),
            'description' => $t->app->_random_string( 256 ),
            upload => { file => $picture_path . 'all_right2.svg' }
        },
        'result' => {
            'id'        => $answer + 2,
            'status'    => 'ok'
        },
        'comment' => 'Data only as phone:'
    },
    3 => {
        'data' => {
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'password'    => $t->app->_random_string( 32 ),
            'description' => $t->app->_random_string( 256 ),
            upload => { file => $picture_path . 'all_right3.svg' }
        },
        'result' => {
            'id'        => $answer + 3,
            'status'    => 'ok'
        },
        'comment' => 'No data:'
    },
    4 => {
        'data' => {
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'password'    => $t->app->_random_string( 32 ),
            'patronymic' => $t->app->_random_string( 24 ),
        },
        'result' => {
            'id'        => $answer + 4,
            'status'    => 'ok'
        },
        'comment' => 'No doc:'
    },
    5 => {
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
        },
        'result' => {
            'id'        => $answer + 5,
            'status'    => 'ok'
        },
        'comment' => 'Doc only as description:'
    },
    6 => {
        'data' => {
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'password'    => $t->app->_random_string( 32 ),
            'patronymic' => $t->app->_random_string( 24 ),
            upload => { file => $picture_path . 'all_right4.svg' }
        },
        'result' => {
            'id'        => $answer + 6,
            'status'    => 'ok'
        },
        'comment' => 'No description:'
    },

    # отрицательные тесты
    7 => {
        'data' => {
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => 'qwerty',
            'password'    => $t->app->_random_string( 32 ),
            'description' => $t->app->_random_string( 256 ),
            'patronymic' => $t->app->_random_string( 24 ),
            upload => { file => $picture_path . 'all_right5.svg' }
        },
        'result' => {
            'message'   => "/user/add _check_fields: empty field 'phone', didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong input format:'
    },
    8 => {
        'data' => {
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => 'temp',
            'email'     => $t->app->_random_string( 24 ),
            'phone'    => '7(921)1111111',
            'password'    => $t->app->_random_string( 32 ),
            'description' => $t->app->_random_string( 256 ),
            'patronymic' => $t->app->_random_string( 24 ),
            upload => { file => $picture_path . 'all_right5.svg' }
        },
        'result' => {
            'message'    => "login temp already used",
            'status'     => 'fail'
        },
        'comment' => 'Same login:'
    },
    9 => {
        'data' => {
            'name'      => $t->app->_random_string( 24 ),
            'surname'     => $t->app->_random_string( 24 ),
            'status'    => 1,
            'login'      => $t->app->_random_string( 16 ),
            'email'     => 'temp',
            'phone'    => '7(921)1111111',
            'password'    => $t->app->_random_string( 32 ),
            'description' => $t->app->_random_string( 256 ),
            'patronymic' => $t->app->_random_string( 24 ),
            upload => { file => $picture_path . 'all_right5.svg' }
        },
        'result' => {
            'message'    => "email temp already used",
            'status'     => 'fail'
        },
        'comment' => 'Same email:'
    },
    10 => {
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
            upload => { file => $picture_path . 'all_right1.svg' }
        },
        'result' => {
            'message'    => "file with this name already used",
            'status'     => 'fail'
        },
        'comment' => 'Same upload filename:'
    },
    11 => {
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
            upload => { file => $picture_path . 'wrong_extension.wrong_extension' }
        },
        'result' => {
            'message'    => "/user/add _check_fields: extension wrong_extension is not valid",
            'status'    => 'fail'
        },
        'comment' => 'Wrong extension:'
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};

    $t->post_ok( $host.'/user/add' => {token => $token}  => form => $data );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect \n");
        last;
    }
    $t->content_type_is('application/json;charset=UTF-8');
    $t->json_is( $result );

    diag "";
};

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'        => $answer + 1
        },
        'result' => {
            'id'        => $answer + 1,
            'status'    => 'ok'
        },
        'comment' => 'All right:' 
    },
    2 => {
        'data' => {
            'id'        => $answer + 2
        },
        'result' => {
            'id'        => $answer + 2,
            'status'    => 'ok'
        },
        'comment' => 'All right:' 
    },
    3 => {
        'data' => {
            'id'        => $answer + 3
        },
        'result' => {
            'id'        => $answer + 3,
            'status'    => 'ok'
        },
        'comment' => 'All right:' 
    },
    4 => {
        'data' => {
            'id'        => $answer + 4
        },
        'result' => {
            'id'        => $answer + 4,
            'status'    => 'ok'
        },
        'comment' => 'All right:' 
    },
    5 => {
        'data' => {
            'id'        => $answer + 5
        },
        'result' => {
            'id'        => $answer + 5,
            'status'    => 'ok'
        },
        'comment' => 'All right:' 
    },
    6 => {
        'data' => {
            'id'        => $answer + 6
        },
        'result' => {
            'id'        => $answer + 6,
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