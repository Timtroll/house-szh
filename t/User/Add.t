use Mojo::Base -strict;

use FindBin;
BEGIN {
    unshift @INC, "$FindBin::Bin/../../lib";
}

use Test::More;
use Test::Mojo;
use Mojo::JSON qw( decode_json );
use Data::Dumper;

my ( $t, $host, $picture_path, $test_data, $extension, $regular, $file_path, $desc_path, $cmd, $data, $result, $response, $token, $url, $size, $description );
$t = Test::Mojo->new('Houseapp');

# Устанавливаем адрес
$host = $t->app->config->{'host'};

# clear_db();

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

$test_data = {
    # положительные тесты
    1 => {
        'data' => {
            'name'      => 'name1',
            'surname'     => 'surname1',
            'status'    => 1,
            'login'      => 'login',
            'email'     => 'email',
            'phone'    => 'phone',
            'password'    => 'password',
            'description' => 'description',
            upload => { file => $picture_path . 'all_right.svg' }
        },
        'result' => {
            'id'        => '1',
            'status'    => 'ok'
        },
        'comment' => 'All fields:'
    },

    # отрицательные тесты
    2 => {
        'data' => {
            'surname'     => 'surname2',
            'status'    => 1,
            'login'      => 'login2',
            'email'     => 'email2',
            'phone'    => 'phone2',
            'password'    => 'password2',
            'description' => 'description2',
            upload => { file => $picture_path . 'all_right.svg' }
        },
        'result' => {
            'message'   => "/user/add _check_fields: empty field 'name', didn't match regular expression",
            'status'    => 'fail'
        },
        'comment' => 'Wrong input format:'
    },
    3 => {
        'data' => {
            'name'      => 'name1',
            'surname'     => 'surname3',
            'status'    => 1,
            'login'      => 'login3',
            'email'     => 'email3',
            'phone'    => 'phone3',
            'password'    => 'password3',
            'description' => 'description3',
            upload => { file => $picture_path . 'all_right.svg' }
        },
        'result' => {
            'message'    => "name 'name1' already exists",
            'status'     => 'fail'
        },
        'comment' => 'Same name:'
    },
    4 => {
        'data' => {
            'name'      => 'name1',
            'surname'     => 'surname4',
            'status'    => 1,
            'login'      => 'login4',
            'email'     => 'email4',
            'phone'    => 'phone4',
            'password'    => 'password4',
            'description' => 'description4',
            upload => { file => $picture_path . 'all_right.svg' }
        },
        'result' => {
            'message'    => "surname 'surname1' already exists",
            'status'     => 'fail'
        },
        'comment' => 'Same surname:'
    },
    5 => {
        'data' => {
            'name'      => 'name5',
            'surname'     => 'surname5',
            'status'    => 1,
            'login'      => 'login5',
            'email'     => 'email5',
            'phone'    => 'phone5',
            'password'    => 'password5',
            'description' => 'description5',
            upload => { file => $picture_path . 'no_extension' }
        },
        'result' => {
            'message'    => "surname 'surname1' already exists",
            'status'     => 'fail'
        },
        'comment' => 'Same surname:'
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

    # # проверка данных ответа
    # $response = decode_json $t->{'tx'}->{'res'}->{'content'}->{'asset'}->{'content'};
    # # url проверяется отдельно, так как оно генерируется случайно
    # $url = $$response{'url'};
    # delete $response->{'url'};
    # ok( Compare( $result, $response ), "Response is correct" );

    # # дополнительные проверки работы положительных запросов
    # if ( $$result{'status'} eq 'ok' ) {

    #     # составление списка возможных расширений
    #     $extension = '(';
    #     foreach ( keys %{$settings->{'valid_extensions'}} ) {
    #         $extension = $extension . $_ . '|';
    #     }
    #     $extension =~ s/\|$/)/;

    #     # регулярное выражение для проверки url
    #     $regular = '^' . $settings->{'site_url'} . $settings->{'upload_url_path'} . '([\w]{48}' . ').(' . $extension . ')$';
    #     ok( $url =~ /$regular/, "Url is correct" );

    #     # проверка размера загруженного файла
    #     $file_path = $settings->{'upload_local_path'} . $1 . '.' . $2;
    #     ok( -s $file_path == $size, "Download was successful");

    #     # проверка содержимого файла описания
    #     $desc_path = $settings->{'upload_local_path'} . $1 . '.' . $settings->{'desc_extension'};
    #     $description = read_file( $desc_path, { binmode => ':utf8' } );
    #     $description = decode_json $description;

    #     ok( 
    #         $$description{'description'} eq $$data{'description'} &&
    #         $$description{'mime'} eq $$result{'mime'} &&
    #         $$description{'filename'} eq $1 &&
    #         $$description{'extension'} eq $2 &&
    #         $$description{'title'} eq 'all_right.svg' &&
    #         $$description{'size'} == $size,
    #         "Description is correct"
    #     );

    #     # удаление загруженных файлов
    #     $cmd = `rm $file_path $desc_path`;
    #     ok( !$?, "Files were deleted");
    # }
    diag "";
};
# clear_db();

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

