package Houseapp::Helpers::Utils;

use utf8;
use strict;
use warnings;

use base 'Mojolicious::Plugin';
use Mojo::JSON qw/decode_json/;

use common;
use Data::Dumper;

use constant DEBUGGING => 1;

sub register {
    my ($self, $app) = @_;

    # генерация строки из случайных букв и цифр
    # my $string = _random_string( length );
    # возвращается строка
    $app->helper('_random_string' => sub {
        my ( $self, $length ) = @_;

        return unless $length =~ /^\d+$/;

        my @chars = ( "A".."Z", "a".."z", 0..9 );
        my $string = join("", @chars[ map { rand @chars } ( 1 .. $length ) ]);

    });

    # проверка на наличие файла в директории
    # my $true = _exists_in_directory( directory/file.extension );
    # возвращается true/false
    $app->helper('_exists_in_directory' => sub {
        my ($self, $directory) = @_;

        return unless $directory;

        return -f $directory;
    });
}

# проверяем наличие таблицы и указанное поле на дубликат
# my $row = $self->model('Utils')->_exists_in_table(<table>, '<id>', <value>, <exclude_id>);
#  <table>       - имя таблицы, где будем искать
#  <id>         - название поле, которое будем искать
#  <value>      - значение поля, которое будем искать
#  <exclude_id>  - исключаем указанный id
# возвращается 1/undef
sub _exists_in_table {
    my ($self, $table,  $name, $val, $exclude_id) = @_;

    return unless $name;

    # Проверяем наличие таблицы в базе данных
    my $sql = "SELECT count(*) FROM pg_catalog.pg_tables WHERE schemaname != 'information_schema' and schemaname != 'pg_catalog' and tablename = '".$table."'";

    my $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();
    my $row = $sth->fetchrow_hashref();
    $sth->finish();

    return unless $row->{'count'};

    # проверяем поле name на дубликат
    $sql = 'SELECT id FROM "public"."'.$table.'" WHERE "'.$name.'"=\''.$val."'";
    # исключаем из поиска id
    $sql .='AND "id" <> '.$exclude_id if $exclude_id;

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();
    $row = $sth->fetchrow_hashref();
    $sth->finish();

    return $row->{'id'} ? 1 : 0;
}

# включение/отключение (1/0) определенного поля в указанной таблице по id
# my $true = $self->model('Utils')->_toggle_route( <table>, <id>, <field>, <val> );
# <id>    - id записи 
# <field> - имя поля в таблице
# <val>   - 1/0
# возвращается true/false
sub _toggle {
    my ($self, $data) = @_;

    return unless ( $data || $$data{'table'} || $$data{'id'} || $$data{'fieldname'} || $$data{'value'} );

    my $result;
    my $sql ='UPDATE "public"."'.$$data{'table'}.'" SET "'.$$data{'fieldname'}.'"='.$$data{'value'}.' WHERE "id"='.$$data{'id'};

    $result = $self->{app}->pg_dbh->do($sql);
    $result = $result ? $result : 0;

    return $result;
}

1;
