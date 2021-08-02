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

    # проверяем, занят ли логин
    if ( $self->model('Utils')->_exists_in_table('users', 'login', $$data{'login'} ) ) {
        push @!, "login $$data{'login'} already used"; 
    }
    # проверяем, занят ли емэйл
    if ( $self->model('Utils')->_exists_in_table('users', 'email', $$data{'email'} ) ) {
        push @!, "email $$data{'email'} already used"; 
    }

    unless ( @! ) {
        # получение соли из конфига
        $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];

        # преобразование пароля
        $$data{'password'} = sha256_hex( $$data{'password'}, $salt );

        $$data{'id'} = $self->model('User')->_insert_user( $data );
    }

    unless ( @! ) {
        if ( $$data{'name'} || $$data{'surname'} || $$data{'patronymic'} || $$data{'phone'} ) {
            $id = $self->model('User_data')->_insert_data( $data );
        }
    }

    unless ( @! ) {
        if ( $$data{'content'} ) {
            # store real file name
            $$data{'title'} = $$data{'filename'};

            # генерация имени файла
            $$data{'filename'} = sha256_hex( $$data{'filename'}, $salt );

            # присвоение пустого значения вместо null
            $$data{'description'} = '' unless ( $$data{'description'} );

            # получение точного времени
            $$data{'time_create'} = $self->model('Utils')->_sec2date( time() );

            # запись файла
            my $res = write_file(
                $config->{'upload_local_path'} . $$data{'filename'} . '.' . $$data{'extension'},
                { binmode => ':utf8' },
                $$data{'content'}
            );
            push @!, "Can not store '$$data{'filename'}' file" unless $res;

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
                my $local_path = $config->{'upload_local_path'};
                my $extension = $config->{'desc_extension'};
                my $write_result = write_file(
                    $local_path . $$data{'filename'} . '.' . $extension,
                    { binmode => ':utf8' },
                    $json
                );
                push @!, "Can not write desc of $$data{'title'}" unless $write_result;
            }
        }
    }

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'id'} = $$data{'id'} if $$data{'id'};
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
        $$data{'table'} = 'users';

        unless ( $self->model('Utils')->_exists_in_table( $$data{'table'}, 'id', $$data{'id'} ) ) {
            push @!, "user with id '$$data{'id'}' doesn't exist";
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
        $$data{'table'} = 'users';

        unless ( $self->model('Utils')->_exists_in_table( $$data{'table'}, 'id', $$data{'id'} ) ) {
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

    my ( $delete, $resp, $data, $fileinfo, $filename, $local_path, $full_path, $cmd, $data_id, $doc_id );

    # проверка данных
    $data = $self->_check_fields();

    # проверка существования элемента для изменения
    unless ( @! ) {
        $$data{'table'} = 'users';

        unless ( $self->model('Utils')->_exists_in_table( $$data{'table'}, 'id', $$data{'id'} ) ) {
            push @!, "user with '$$data{'id'}' doesn't exist";
        }
        unless ( @! ) {
            $delete = $self->model('User')->_delete( $data );
            push @!, "Could not delete User '$$data{'id'}'" unless $delete;
        }
        unless ( @! ) {
            $data_id = $self->model('User_data')->_get_id( $$data{'id'} );
            if ( $data_id ) {
                $delete = $self->model('User_data')->_delete( $data_id );
                push @!, "Could not delete Data '$$data{'id'}'" unless $delete;
            }
        }

        unless ( @! ) {
            $doc_id = $self->model('User_doc')->_get_id( $$data{'id'} );
        }
        if ( $doc_id ) {
            unless ( @! ) {
                $fileinfo = $self->model('User_doc')->_check_media( $doc_id );
            }
            # удаление файла
            unless ( @! ) {
                $filename = $$fileinfo{'new_name'} . '.' . $$fileinfo{'extension'};
                $local_path = $config->{'upload_local_path'};
                $full_path = $local_path . $filename;
                if ( $self->_exists_in_directory( $full_path ) ) {
                    my $cmd = `rm $full_path`;
                    if ( $? ) {
                        push @!, "Can not delete $full_path, $?";
                    }
                }
            }
            # удаление описания файла
            unless ( @! ) {
                $filename = $$fileinfo{'new_name'} . '.' . 'desc';
                $full_path = $local_path . $filename;
                if ( $self->_exists_in_directory( $full_path ) ) {
                    my $cmd = `rm $full_path`;
                    if ( $? ) {
                        push @!, "Can not delete $full_path description, $?";
                    }
                }
            }
            unless ( @! ) {
                $delete = $self->model('User_doc')->_delete_media( $doc_id );
                push @!, "Could not delete Media '$$data{'id'}'" unless $delete;
            }
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

    my ( $result_user, $data_id, $result_data, $data, $doc_id, $result_doc, $result, $resp );

    # проверка данных
    $data = $self->_check_fields();

    unless ( @! ) {
        unless ( $self->model('Utils')->_exists_in_table('users', 'id', $$data{'id'} ) ) {
            push @!, "Could not get User '$$data{'id'}'";
        }
    }

    unless ( @! ) {
        $result_user = $self->model('User')->_get_user( $$data{'id'} );
    }
    unless ( @! ) {
        $data_id = $self->model('User_data')->_get_id( $$data{'id'} );
        if ( $data_id ) {
            $result_data = $self->model('User_data')->_get_data( $data_id );
        }
    }
    unless ( @! ) {
        $doc_id = $self->model('User_doc')->_get_id( $$data{'id'} );
        if ( $doc_id ) {
            $result_doc = $self->model('User_doc')->_get_media( $doc_id );
        }
    }

    unless ( @! ) {
        $$result{'id'}     = $$result_user{'id'};
        $$result{'login'}  = $$result_user{'login'};
        $$result{'email'}  = $$result_user{'email'};
        $$result{'status'} = $$result_user{'status'};

        if ( $result_data ) {
            $$result{'surname'}    = $$result_data{'surname'} if $$result_data{'surname'};
            $$result{'name'}       = $$result_data{'name'} if $$result_data{'name'};
            $$result{'patronymic'} = $$result_data{'patronymic'} if $$result_data{'patronymic'};
            $$result{'phone'}      = $$result_data{'phone'} if $$result_data{'phone'};
        }

        if ( $result_doc ) {
            $$result{'extension'}     = $$result_doc{$doc_id}{'extension'};
            $$result{'filename'}      = $$result_doc{$doc_id}{'new_name'};
            $$result{'size'}          = $$result_doc{$doc_id}{'size'};
            $$result{'real_filename'} = $$result_doc{$doc_id}{'old_name'};

            $$result{'url'} = $config->{'site_url'} . $config->{'upload_url_path'} . $$result{'filename'};
            $$result{'mime'} = $config->{'valid_extensions'}->{$$data{'extension'}};
        }
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = $result unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub save {
    my ( $self ) = shift;

    my ( $id, $result, $data, $salt, $resp );


    # проверка данных
    $data = $self->_check_fields();

    # проверка существования обновляемой строки
    unless ( @! ) {
        unless ( $self->model('Utils')->_exists_in_table('users', 'id', $$data{'id'}) ) {
            push @!, "User with id '$$data{'id'}' does not exist";
        }
    }

    # проверка паролей
    unless ( @! ) {
        if ( $$data{'password'} && !$$data{'newpassword'} ) {
            push @!, 'Empty newpassword';
        }
        elsif ( !$$data{'password'} && $$data{'newpassword'} ) {
            push @!, 'Empty password';
        }
        elsif ( $$data{'password'} && $$data{'password'} eq $$data{'newpassword'} ) {
            push @!, 'Password and newpassword are the same';
        }
    }

    unless ( @! ) {
        # проверяем, используется ли логин другим пользователем
        if ( $$data{'login'} && $self->model('Utils')->_exists_in_table('users', 'login', $$data{'login'}, $$data{'id'} ) ) {
            push @!, "login '$$data{ login }' already used"; 
        }
        # проверяем, используется ли емэйл другим пользователем
        elsif ( $$data{'email'} && $self->model('Utils')->_exists_in_table('users', 'email', $$data{'email'}, $$data{'id'} ) ) {
            push @!, "email '$$data{ email }' already used"; 
        }
    }

    unless ( @! ) {
        if ( $$data{'password'} ) {
            # получение соли из конфига
            $salt = $self->{'app'}->{'config'}->{'secrets'}->[0];

            # преобразование пароля
            $$data{'password'} = sha256_hex( $$data{'newpassword'}, $salt );
        }

        $id = $self->model('User')->_update_users( $data );
    }
    unless ( @! ) {
        if ( $$data{'name'} || $$data{'surname'} || $$data{'patronymic'} || $$data{'phone'} ) {
            $result = $self->model('User_data')->_update_data( $data );
        }
    }
    unless ( @! ) {
        $result = $self->model('User_doc')->_update_media( $data );
    }

    $resp->{'message'} = join("\n", @!) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'id'} = $id unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

1;