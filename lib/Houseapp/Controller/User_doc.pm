package Houseapp::Controller::User_doc;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use common;
use Data::Dumper;

sub index {
    my $self = shift;

    my ( $data, $result, $filename, $resp, $url, $json, $local_path, $extension, $write_result, $name_length );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };    

    # проверка данных
    unless ( @! ) {
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        # store real file name
        $$data{'title'} = $$data{'filename'};

        # генерация случайного имени
        $$data{'filename'} = sha256_hex( $$data{'filename'}, $salt );

        # путь файла
        $$data{'path'} = 'local';
        # присвоение пустого значения вместо null
        $$data{'description'} = '' unless ( $$data{'description'} );

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
        $result = $self->model('Upload')->_insert_media( $data );
    }

    # преобразование данныхв json
    unless ( @! ) {
        delete $$data{'content'};
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

sub delete {
    my $self = shift;

    my ( $data, $fileinfo, $result, $resp, $filename, $cmd, $local_path, $full_path );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    # проверка данных
    unless ( @! ) {
        $data = $self->_check_fields();
    }

    # получение данных об удаляемом файле из базы данных
    unless ( @! ) {
        $fileinfo = $self->model('Upload')->_check_media( $$data{'id'} );
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

    # удаление записи о файле
    unless ( @! ) {
        $data = $self->model('Upload')->_delete_media( $$data{'id'} );
    }

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';

    @! = ();

    $self->render( 'json' => $resp );
}

sub search {
    my $self = shift;

    my ( $data, $resp, $url, $host, $url_path, @data );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    # проверка данных
    unless ( @! ) {
        $data = $self->_check_fields();
    }

    # получение записи
    unless ( @! ) {
        $data = $self->model('Upload')->_get_media( $data );
    }

    # добавление данных об url
    unless ( @! ) {
        $host = $config->{'site_url'};
        $url_path = $config->{'upload_url_path'};
        foreach my $row ( values %{$data} ) {
            $url = $host . $url_path . $$row{'filename'} . '.' . $$row{'extension'};
            delete @{$row}{'filename', 'extension'};
            push @data, { %$row, 'url' => $url };
        }
    }

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';
    $resp->{'data'} = \@data unless @!;

    @! = ();

    $self->render( 'json' => $resp );
}

sub update {
    my $self = shift;

    my ( $data, $url, $resp, $host, $local_path, $url_path, $desc_extension, $json, $rewrite_result );
    push @!, "Validation list not contain rules for this route: ".$self->url_for unless keys %{ $$vfields{ $self->url_for } };

    # проверка данных
    unless ( @! ) {
        $data = $self->_check_fields();
    }

    unless ( @! ) {
        # присвоение пустого значения вместо null
        $$data{'description'} = '' unless ( $$data{'description'} );

        # обновление записи
        $data = $self->model('Upload')->_update_media( $data );
    }

    # преобразование данных в json
    unless ( @! ) {
        $json = encode_json ( $data );
        push @!, "Can not convert into json $$data{'title'}" unless $json;
    }

    # запись нового файла с описанием
    $host = $config->{'site_url'};
    $local_path = $config->{'upload_local_path'};
    $url_path = $config->{'upload_url_path'};
    $desc_extension = $config->{'desc_extension'};
    unless ( @! ) {
        $rewrite_result = write_file(
            $local_path . $$data{'filename'} . '.' . $desc_extension,
            { binmode => ':utf8' },
            $json
        );
        push @!, "Can not update description of $$data{'title'}" unless $rewrite_result;
    }

    unless ( @! ) {
        $url = $host . $url_path . $$data{'filename'} . '.' . $$data{'extension'};
    }

    $resp->{'message'} = join( "\n", @! ) if @!;
    $resp->{'id'} = $$data{'id'} unless @!;
    $resp->{'mime'} = $$data{'mime'} unless @!;
    $resp->{'url'} = $url unless @!;
    $resp->{'status'} = @! ? 'fail' : 'ok';

    @! = ();

    $self->render( 'json' => $resp );
}

1;