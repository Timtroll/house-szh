package Houseapp::Model::User_data;

use Mojo::Base 'Houseapp::Model::Base';

use Data::Dumper;

use DBD::Pg;
use DBI;

use common;

sub _insert_data {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }

    unless ( @! ) {
        $sql = 'INSERT INTO "public"."user_data" ( "name", "surname", "phone", "patronymic" ) VALUES ( :name, :surname, :phone, :patronymic )';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':name', $$data{'name'} );
        $sth->bind_param( ':surname', $$data{'surname'} );
        $sth->bind_param( ':phone', $$data{'phone'} );
        $sth->bind_param( ':patronymic', $$data{'patronymic'} );
        $sth->execute();
        $sth->finish();

        $id = $sth->last_insert_id( undef, 'public', 'user_data', undef, { sequence => 'data_id_seq' } );
        $sth->finish();
        push @!, "Can not insert data into user_data" unless $id;
    }

    unless ( @! ) {
        $sql = 'INSERT INTO "public"."user_links" ( "first_id", "first_type", "second_id", "second_type" ) VALUES ( :first_id, :first_type, :second_id, :second_type )';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':first_id', $$data{'id'} );
        $sth->bind_param( ':first_type', 'user' );
        $sth->bind_param( ':second_id', $id );
        $sth->bind_param( ':second_type', 'user_data' );
        $sth->execute();
        $sth->finish();
    }

    return $id;
}

sub _get_list {
    my $self = shift;

    my ( $sql, $sth, $user_data, $list );

    # получаем список групп
    $sql = 'SELECT id,label FROM "public"."user_data"';

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();

    $user_data = $sth->fetchall_hashref( 'id' );
    $sth->finish();
    push @!, "couldn't get list of user_data" unless $user_data;

    return $user_data;
}

sub _get_data {
    my ( $self, $id ) = @_;

    return unless $id;

    my ( $result, $row, $sql, $sth, $data_id );

    unless( @! ) {
        $sql = 'SELECT * FROM "public"."user_data" WHERE "id" = :id';
        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $id );
        $sth->execute();
        $row = $sth->fetchrow_hashref();
        $sth->finish();
    }

    return $row;
}

sub _update_data {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth, $result );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for update";
    }

    unless ( @! ) {
        $sql = 'UPDATE "public"."user_data" SET "name" = :name, "surname" = :surname, "patronymic" = :patronymic, "phone" = :phone WHERE "id" = :id returning id';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':name', $$data{'name'} );
        $sth->bind_param( ':surname', $$data{'surname'} );
        $sth->bind_param( ':patronymic', $$data{'patronymic'} );
        $sth->bind_param( ':phone', $$data{'phone'} );
        $sth->bind_param( ':id', $$data{'id'} );
        $sth->execute();
        $result = $sth->fetchrow_array();
        $sth->finish();

        push @!, "Error by update data" if ! defined $result;
    }

    return $result;
}

sub _delete {
    my ( $self, $id ) = @_;

    my ( $sql, $sth, $result, $data_id );

    push @!, 'no id' unless $id;


    unless( @! ) {
        # удаление записи из таблицы user_data
        $sql = 'DELETE FROM "public"."user_data" WHERE "id" = :id';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $id );
        $result = $sth->execute();
        $sth->finish();

        push @!, "Could not delete user_data '$id'" if $result eq '0E0';
    }

    unless( @! ) {
        # удаление записи из таблицы user_links
        $sql = 'DELETE FROM "public"."user_links" WHERE "second_id" = :id and "second_type" = :data';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $id );
        $sth->bind_param( ':data', 'user_data' );
        $result = $sth->execute();
        $sth->finish();

        push @!, "Could not delete user_links '$id'" if $result eq '0E0';
    }

    return $result;
}

sub _get_id {
    my ( $self, $id ) = @_;

    my ( $sql, $sth, $result, $data_id );

    push @!, 'no id' unless $id;

    unless( @! ) {
        # получение id из таблицы user_links
        $sql = 'SELECT second_id FROM "public"."user_links" WHERE "first_id" = :id and "second_type" = :data';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $id );
        $sth->bind_param( ':data', 'user_data' );
        $sth->execute();
        $result = $sth->fetchrow_hashref();
        $sth->finish();
        $data_id = $$result{'second_id'};
    }
    return $data_id;
}

1;