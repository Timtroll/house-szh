use Mojo::Base -strict;

use FindBin;
BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

use Test::More;
use Test::Mojo;
use Mojo::JSON qw( decode_json );
use Data::Dumper;

my $t = Test::Mojo->new('Houseapp');

# Устанавливаем адрес
my $host = $t->app->config->{'host'};

# clear_db();

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
diag "Add user:";
my $data = {
            'name'      => 'nameedit',
            'surname'     => 'surnameedit',
            "patronymic"=>      "patronymicedit",
            'status'    => 1,
            'login'      => 'loginedit',
            'email'     => 'emailedit',
            'phone'    => '7(921)1111111',
            'password'    => 'passwordedit',
            'description' => 'descriptionedit',
            upload => { file => $picture_path . 'all_right_edit.svg' }
};
$t->post_ok( $host.'/user/add' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";

# получение id последнего элемента
my $answer = get_last_id_user( $t->app->pg_dbh );

my $test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'id'    => $answer
        },
        'result' => {
            'data'      => {
                'id'        => $answer,
                "login"=>           "loginedit",
                "email"=>           "emailedit",
                "status"=>          1,
                "surname"=>         "surnameedit",
                "name"=>            "nameedit",
                "patronymic"=>      "patronymicedit",
                "phone"=>           "7(921)1111111",
                "extension"=>        "svg",
                "filename"=>         "4eba754906d4dc493609ea6c980b4b029123353d5556f39cd3fecaad792f7f94",
                "url"=>              "http://house/home/simon/work/house-szh/public/uploads/4eba754906d4dc493609ea6c980b4b029123353d5556f39cd3fecaad792f7f94.svg",
                "mime"=>             "image/svg+xml",
                "size"=>             3038,
                "real_filename"=>    "all_right_edit.svg"
            },
            'status'    => 'ok'
        },
        'comment' => 'All right:'
    },

    # отрицательные тесты
    2 => {
        'data' => {
            'id'        => 404
        },
        'result' => {
            'message'   => "Could not get User '404'",
            'status'    => 'fail'
        },
        'comment' => 'Wrong id:' 
    },
    3 => {
        'result' => {
            'message'   => "/user/edit _check_fields: didn't has required data in 'id' = ''",
            'status'    => 'fail'
        },
        'comment' => 'No data:' 
    },
    4 => {
        'data' => {
            'id'        => - 404
        },
        'result' => {
            'message'   => "/user/edit _check_fields: empty field 'id', didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong input format:' 
    }
};

foreach my $test (sort {$a <=> $b} keys %{$test_data}) {
    diag ( $$test_data{$test}{'comment'} );
    my $data = $$test_data{$test}{'data'};
    my $result = $$test_data{$test}{'result'};
    $t->get_ok($host.'/user/edit' => {token => $token} => form => $data )
        ->status_is(200)
        ->content_type_is('application/json;charset=UTF-8')
        ->json_is( $result );
    diag "";
};


# Ввод данных для вывода
diag "Delete user:";
$data = {
            'id'      => $answer,
};
$t->get_ok( $host.'/user/delete' => {token => $token} => form => $data );
unless ( $t->status_is(200)->{tx}->{res}->{code} == 200  ) {
    diag("Can't connect");
    last;
}
$t->content_type_is('application/json;charset=UTF-8');
diag "";


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