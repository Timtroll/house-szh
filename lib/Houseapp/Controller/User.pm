package Houseapp::Controller::User;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use common;
use Data::Dumper;
use Digest::SHA qw( sha256_hex );
use Mojo::JSON qw( encode_json );

sub add {
    my $self = shift;

    my ( $id, $data, $result, $filename, $resp, $url, $json, $local_path, $extension, $write_result, $name_length, $salt );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        # получение соли из конфига
        $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];

        # преобразование паоля
        $$data{'password'} = sha256_hex( $$data{'password'}, $salt );

        $$data{'id'} = $self->model('User')->_insert_user( $data );
    }

    unless ( @! ) {
        $id = $self->model('User_data')->_insert_data( $data );
    }

    unless ( @! ) {
        # store real file name
        $$data{'title'} = $$data{'filename'};

        # генерация случайного имени
        $$data{'filename'} = sha256_hex( $$data{'filename'}, $salt );

        # присвоение пустого значения вместо null
        $$data{'description'} = '' unless ( $$data{'description'} );

        # получение точного времени
        $$data{'time_create'} = $self->model('Utils')->_sec2date( time() );

        # получение mime
        $$data{'mime'} = $config->{'valid_extensions'}->{$$data{'extension'}} || '';

        # запись файла
        $result = write_file(
            $config->{'upload_local_path'} . $$data{'filename'} . '.' . $$data{'extension'},
            { binmode => ':utf8' },
            $$data{'content'}
        );
        push @!, "Can not store '$$data{'filename'}' file" unless $result;
    }

    # ввод данных в таблицу
    unless ( @! ) {
        $result = $self->model('User_doc')->_insert_media( $data );
    }

    # преобразование данных в json
    unless ( @! ) {
        # delete $$data{'content'};
        $json = encode_json ( $data );
        push @!, "Can not convert into json $$data{'title'}" unless $json;
    }

    # создание файла с описанием
    unless ( @! ) {
        $local_path = $config->{'upload_local_path'};
        $extension = $config->{'desc_extension'};
        $write_result = write_file(
            $local_path . $$data{'filename'} . '.' . $extension,
            { binmode => ':utf8' },
            $json
        );
        push @!, "Can not write desc of $$data{'title'}" unless $write_result;
    }

    # получение url
    unless ( @! ) {
        $url = $config->{'site_url'} . $config->{'upload_url_path'} . $$data{'filename'} . '.' . $$data{ 'extension' };
    }

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'id'} = $result if $result;
    $resp->{'mime'} = $$data{'mime'} if $result;
    $resp->{'url'} = $url if $url;
    $resp->{'status'} = @! ? 'fail' : 'ok';

    @! = ();

    $self->render( 'json' => $resp );
}

sub index {
    my $self = shift;

    my ( $data, $user_data, $resp, $users );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        $$data{'page'} = 1 unless $$data{'page'};
        $$data{'limit'}  = $config->{'per_page'};
        $$data{'offset'} = ( $$data{'page'} - 1 ) * $$data{'limit'};

        # получаем список пользователей
        $users = $self->model('User')->_get_list( $data );
    }

    unless ( @! ) {
        # получаем список данных о пользователях
        $user_data = $self->model('User_data')->_get_list( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'users'} = $users unless @!;
    $resp->{'data'} = $user_data unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub activate {
    my $self = shift;

    my ( $toggle, $resp, $data );

    # проверка данных
    $data = $self->_check_fields();

    # проверка существования элемента для изменения
    unless ( @! ) {
        $$data{'table'} = 'user';

        unless ( $self->model('Utils')->_exists_in_table( 'user', 'id', $$data{'id'} ) ) {
            push @!, "user with '$$data{'id'}' doesn't exist";
        }
        unless ( @! ) {
            $toggle = $self->model('Utils')->_activate( $data );
            push @!, "Could not toggle Data '$$data{'id'}'" unless $toggle;
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub deactivate {
    my $self = shift;

    my ( $toggle, $resp, $data );

    # проверка данных
    $data = $self->_check_fields();

    # проверка существования элемента для изменения
    unless ( @! ) {
        $$data{'table'} = 'user';

        unless ( $self->model('Utils')->_exists_in_table( 'user', 'id', $$data{'id'} ) ) {
            push @!, "user with '$$data{'id'}' doesn't exist";
        }
        unless ( @! ) {
            $toggle = $self->model('Utils')->_deactivate( $data );
            push @!, "Could not toggle Data '$$data{'id'}'" unless $toggle;
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub delete {
    my $self = shift;

    my ( $delete, $resp, $data, $fileinfo, $filename, $local_path, $full_path, $cmd );

    # проверка данных
    $data = $self->_check_fields();

    # проверка существования элемента для изменения
    unless ( @! ) {
        $$data{'table'} = 'user';

        unless ( $self->model('Utils')->_exists_in_table( 'user', 'id', $$data{'id'} ) ) {
            push @!, "user with '$$data{'id'}' doesn't exist";
        }
        unless ( @! ) {
            $delete = $self->model('User')->_delete( $data );
            push @!, "Could not delete User '$$data{'id'}'" unless $delete;
        }
        unless ( @! ) {
            $delete = $self->model('User_data')->_delete( $data );
            push @!, "Could not delete Data '$$data{'id'}'" unless $delete;
        }

        unless ( @! ) {
            $fileinfo = $self->model('User_doc')->_check_media( $$data{'id'} );
        }
        # удаление файла
        unless ( @! ) {
            $filename = $$fileinfo{'filename'} . '.' . $$fileinfo{'extension'};
            $local_path = $config->{'upload_local_path'};
            $full_path = $local_path . $filename;
            if ( $self->_exists_in_directory( $full_path ) ) {
                $cmd = `rm $full_path`;
                if ( $? ) {
                    push @!, "Can not delete $full_path, $?";
                }
            }
        }
        # удаление описания файла
        unless ( @! ) {
            $filename = $$fileinfo{'filename'} . '.' . 'desc';
            $full_path = $local_path . $filename;
            if ( $self->_exists_in_directory( $full_path ) ) {
                $cmd = `rm $full_path`;
                if ( $? ) {
                    push @!, "Can not delete $full_path description, $?";
                }
            }
        }
        unless ( @! ) {
            $delete = $self->model('User_doc')->_delete_media( $data );
            push @!, "Could not delete Media '$$data{'id'}'" unless $delete;
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $$data{'id'} unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub edit {
    my $self = shift;

    my ( $result_user, $result_data, $data, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        unless ( $self->model('Utils')->_exists_in_table('users', 'id', $$data{'id'} ) ) {
            push @!, "Could not get User '$$data{'id'}'";
        }
    }

    unless ( @! ) {
        $result_user = $self->model('User')->_get_user( $data );
    }
    unless ( @! ) {
        $result_data = $self->model('User_data')->_get_user( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'user'} = $result_user unless @!;
    $resp->{'data'} = $result_data unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub save {
    my ( $self ) = shift;

    my ( $id, $parent, $data, $resp );


    # проверка данных
    $data = $self->_check_fields();

    # проверка существования обновляемой строки
    unless ( @! ) {
        unless ( $self->model('Utils')->_exists_in_table('groups', 'id', $$data{'id'}) ) {
            push @!, "User with id '$$data{'id'}' does not exist";
        }
    }

    unless ( @! ) {
        $id = $self->model('User')->_update_users( $data );
    }
    unless ( @! ) {
        $id = $self->model('User_data')->_update_data( $data );
    }
    unless ( @! ) {
        $id = $self->model('User_doc')->_update_media( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;