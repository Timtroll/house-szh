package Houseapp::Model::Utils;

use Mojo::Base 'Houseapp::Model::Base';
use Time::Local;

use Data::Dumper;

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

sub _activate {
    my ($self, $data) = @_;

    return unless ( $data || $$data{'table'} || $$data{'id'} );

    my $result;
    my $sql ='UPDATE "public"."'.$$data{'table'}.'" SET "status"=1 WHERE "id"='.$$data{'id'};

    $result = $self->{app}->pg_dbh->do($sql);
    $result = $result ? $result : 0;

    return $result;
}

sub _deactivate {
    my ($self, $data) = @_;

    return unless ( $data || $$data{'table'} || $$data{'id'} );

    my $result;
    my $sql ='UPDATE "public"."'.$$data{'table'}.'" SET "status"=0 WHERE "id"='.$$data{'id'};

    $result = $self->{app}->pg_dbh->do($sql);
    $result = $result ? $result : 0;

    return $result;
}

sub _delete {
    my ($self, $data) = @_;

    return unless ( $data || $$data{'table'} || $$data{'id'} );

    my $result;
    my $sql ='UPDATE "public"."'.$$data{'table'}.'" SET "status"=2 WHERE "id"='.$$data{'id'};

    $result = $self->{app}->pg_dbh->do($sql);
    $result = $result ? $result : 0;

    return $result;
}

# получение значения поля folder по id
# my $true = $self->model('Utils')->_folder_check( <id> );
# возвращается 1/0
sub _folder_check {
    my ( $self, $id ) = @_;

    return unless $id;

    my $sql = 'SELECT "folder" FROM "public"."settings" WHERE "id"='.$id;

    my $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();
    my $result = $sth->fetchrow_hashref();
    $sth->finish();

    return $result->{'folder'} ? 1 : 0;
}

1;