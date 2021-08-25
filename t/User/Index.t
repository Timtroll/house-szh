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


# Ввод данных для вывода
my $test_data = {
    1 => {
        'data' => {
            'name'      => 'name1',
            'surname'     => 'surname1',
            'status'    => 1,
            'login'      => 'login',
            'email'     => 'email',
            'phone'    => '7(921)1111111',
            'password'    => 'password',
            'description' => 'description',
            upload => { file => $picture_path . 'all_right1.svg' }
        },
        'result' => {
            'id'        => '2',
            'status'    => 'ok'
        }
    },
    2 => {
        'data' => {
            'name'      => 'name2',
            'surname'     => 'surname2',
            'status'    => 1,
            'login'      => 'login2',
            'email'     => 'email2',
            'phone'    => '7(921)1111111',
            'password'    => 'password2',
            'description' => 'description',
            upload => { file => $picture_path . 'all_right2.svg' }
        },
        'result' => {
            'id'        => '3',
            'status'    => 'ok' 
        }
    }
};
diag "Create users:";
foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    $t->post_ok( $host.'/user/add' => {token => $token} => form => $$test_data{$test}{'data'} );
    unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
        diag("Can't connect");
        exit; 
    }
    $t->json_is( $$test_data{$test}{'result'} );
}
diag "";

# получение id последнего элемента
my $answer = get_last_id_user( $t->app->pg_dbh );

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'per_page' => 100,
            'page' => 1,
            'sort' => 'ASC',
            'sort_field' => 'id'
        },
        'result' => {
              "users"=>
              [
               [
                1,
                "admin",
                "admin\@admin",
                1,
                undef,
                undef,
                undef,
                undef
               ],
               [
                2,
                "login",
                "email",
                1,
                "surname1",
                "name1",
                "",
                "7(921)1111111"
               ],
               [
                3,
                "login2",
                "email2",
                "1",
                "surname2",
                "name2",
                "",
                "7(921)1111111"
               ]
              ],
              "status"=>"ok"
        },
        'comment' => 'All fields:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    diag ( $$test_data{$test}{'comment'} );
    $t->post_ok($host.'/user/index' => {token => $token} => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
    diag "";
};

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'        => $answer - 1
        },
        'result' => {
            'id'        => $answer - 1,
            'status'    => 'ok'
        },
        'comment' => 'All right:' 
    },
    2 => {
        'data' => {
            'id'        => $answer
        },
        'result' => {
            'id'        => $answer,
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