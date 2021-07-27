package Houseapp::Helpers::Validate;

use utf8;
use strict;
use warnings;


use base 'Mojolicious::Plugin';

use HTML::Strip;

use Data::Dumper;
use Houseapp::Model::Utils;
use common;
use DDP;

# binmode STDOUT, ":utf8";
# binmode STDIN, ":utf8";

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Validation

    # Валидация указанного блока полей и формирование типов
    # my $list = $self->_check_fields();
    # возвращает ссылку на хэш из $self->param(*) + ошибку, если она есть или undef
    $app->helper( '_check_fields' => sub {
        my $self = shift;

        return 0, '_check_fields: No route' unless $self->url_for;

        my $url_for = $self->url_for;
        my %data = ();

        foreach my $field ( sort keys %{$$vfields{$url_for}} ) {
warn $field; 
            # пропускаем роуты, которых нет в хэше валидации
            next unless keys %{ $$vfields{$url_for} };

            my $param = $self->param($field);

            my ( $required, $regexp, $max_size ) = @{ $$vfields{$url_for}{$field} };

            # проверка длины
            if ( defined $param && $max_size && length( $param ) > $max_size ) {
                push @!, "$url_for _check_fields: '$field' has wrong size";
                last;
            }

            # поля которые не могут быть undef
            my %exclude_fields = (
                'parent' => 1,
                'timezone' => 1
            );

            # проверка обязательных полей и исключения
            if ( $required eq 'required' ) {
                if ( exists( $exclude_fields{$field} ) ) {
                    $param = 0 unless $param;
                }
                else {
                    if ( !defined $param || $param eq '' ) {
                        push @!, "$url_for _check_fields: didn't has required data in '$field' = ''";
                        last;
                    }
                }
            }
            elsif ( ! $required && ! $param  ) {
                $data{$field} = '';
                next;
            }
            # проверка для загружаемых файлов
            elsif ( ( $required eq 'file_required' ) && $param ) {
                # проверка наличия содержимого файла
                unless ( $param->{'asset'}->{'content'} ) {
                    push @!, "$url_for _check_fields: no file's content";
                    last;
                }
                $data{'content'} = $param->{'asset'}->{'content'};

                # проверка размера файла
                $data{'size'} = length( $data{'content'} );

                # получение имени файла
                $data{'filename'} = $param->{'filename'};

                # получения расширения файла в нижнем регистре
                $data{'extension'} = '';
                $data{'filename'} =~ /^.*\.(\w+)$/;
                $data{'extension'} = lc $1 if $1;
                unless ( $data{'extension'} ) {
                    push @!, "$url_for _check_fields: can't read extension";
                    last;
                }

                next;
            }
            elsif ( $required eq 'file_required' ) {
                push @!, "$url_for _check_fields: didn't has required file data in '$field'";
                last;
            }

            # проверка для роута toggle по списку значений
            if ( ( $url_for =~ /toggle/ && $field eq 'fieldname' ) && ( ref($regexp) eq 'ARRAY' ) ) {
                unless ( $param && grep( /^$param$/, @{$regexp} ) ) {
                    push @!, "$url_for _check_fields: '$field' didn't match required in check array";
                    last;
                }
            }
            # проверка по списку значений
            elsif ( defined $regexp && ref($regexp) eq 'ARRAY' ) {
                unless ( defined $param && grep( /^$param$/, @{$regexp} ) ) {
                    push @!, "$url_for _check_fields: '$field' did not match required in check array";
                    last;
                }
            }
            # проверка по регэкспу
            else {
                if ( ! defined $param || ! $regexp || ! ( $param =~ /$regexp/ ) ) {
                    push @!, "$url_for _check_fields: empty field '$field', didn't match regular expression";
                    last;
                }
            }

            # проверка country на наличие в хэше возможных значений
            my ( $countries, $timezones );

            if ( $field eq 'country' ) {
                my $countries = $self->_countries();
                unless ( exists $$countries{$param} ) {
                    push @!, "$url_for _check_fields: '$field' doesn't belong to list of valid expressions";
                    last;
                }
            }
            # проверка timezone на наличие в хэше возможных значений
            elsif ( $field eq 'timezone' ) {
                $timezones = $self->_time_zones();
                unless ( exists $$timezones{$param} ) {
                    push @!, "$url_for _check_fields: '$field' doesn't belong to list of valid expressions";
                    last;
                }
            }

            # cохраняем переданные данные
            $data{$field} = $param;
        }
use DDP;
p %data;
        return \%data;
    });

    # загрузка правил валидации html полоей, например:
    # my $list = $self->_param_fields('get_tree');
    # возвращает 1/undef
    $app->helper( '_param_fields' => sub {

        $vfields = {
            '/auth/config'     => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
################
            '/auth/login'  => {
                'login'       => [ 'required', qr/^[\w\-]+$/os, 32 ],
                'password'    => [ 'required', qr/^[\w\~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 32 ],
            },
################
            # роуты user_doc /*
            '/user_doc'  => {
                "upload"        => [ 'file_required', undef, $config->{'upload_max_size'} ],
                "description"   => [ '', qr/^[\w\ \-\~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 256 ]
            },
            '/user_doc/delete'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/user_doc/search'  => {
                "search"        => [ 'required', qr/^[\w\ \-\~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 256 ],
            },
            '/user_doc/update'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "description"   => [ '', qr/^[\w\ \-\~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 256 ]
            },
################
            # роуты user/*
            '/user/index'  => {
                "page"          => [ '', qr/^[\w]+$/os, 256 ],
            },
            '/user/add'  => {
                "login"         => [ 'required', qr/^\w+$/os, 16 ],
                'email'         => [ '', qr/^[\w\@\.]+$/os, 24 ],
                "status"        => [ 'required', qr/^[012]$/os, 1 ],
                'surname'       => [ '', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'name'          => [ '', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'phone'         => [ '', qr/^(8|7)(\s|\-)?(\(\d{3}\))(\s|\-)?[\d]{3}(\s|\-)?[\d]{2}(\s|\-)?[\d]{2}$/os, 18 ],
                'password'      => [ '', qr/^[\w\-\~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 32 ],
                "upload"        => [ 'file_required', undef, $config->{'upload_max_size'} ],
                "description"   => [ '', qr/^[\w\ \-\~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 256 ]
            },
            '/user/edit'  => {
                 "id"           => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/user/save'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                "login"         => [ 'required', qr/^\w+$/os, 16 ],
                'email'         => [ '', qr/^[\w\@\.]+$/os, 24 ],
                "status"        => [ 'required', qr/^[012]$/os, 1 ]
            },
            '/user/delete'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/user/activate'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/user/deactivate'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
################
            # роуты user_data/*
            '/user_data/index'  => {
                "page"          => [ '', qr/^[\w]+$/os, 256 ],
            },
            '/user_data/add'  => {
                'surname'       => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'name'          => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'phone'         => [ '', qr/^(8|7)(\s|\-)?(\(\d{3}\))(\s|\-)?[\d]{3}(\s|\-)?[\d]{2}(\s|\-)?[\d]{2}$/os, 18 ],
                'password'      => [ '', qr/^[\w\-\~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 32 ],
                'newpassword'   => [ '', qr/^[\w\-\~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 32 ]
            },
            '/user_data/edit'  => {
                 "id"           => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/user_data/save'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ],
                'surname'       => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'name'          => [ 'required', qr/^[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя\w\-]+$/os, 24 ],
                'phone'         => [ '', qr/^(8|7)(\s|\-)?(\(\d{3}\))(\s|\-)?[\d]{3}(\s|\-)?[\d]{2}(\s|\-)?[\d]{2}$/os, 18 ],
                'password'      => [ '', qr/^[\w\-\~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 32 ],
                'newpassword'   => [ '', qr/^[\w\-\~\!№\$\@\^\&\%\*\(\)\[\]\{\}=\;\:\|\\\|\/\?\>\<\,\.\/\"\']+$/os, 32 ]
            },
            '/user_data/delete'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/user_data/activate'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            },
            '/user_data/deactivate'  => {
                "id"            => [ 'required', qr/^\d+$/os, 9 ]
            }
        };
 
        return $vfields;
    });
}

1;
