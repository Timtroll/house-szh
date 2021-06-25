package Freee::Model::User_data;

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
        $sql = 'INSERT INTO "public"."user_data" ( "login", "email", "phone", "password" ) VALUES ( :login, :email, :phone, :password )';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':login', $$data{'login'} );
        $sth->bind_param( ':email', $$data{'email'} );
        $sth->bind_param( ':phone', $$data{'phone'} );
        $sth->bind_param( ':password', $$data{'password'} );
        $sth->execute();
        $sth->finish();

        $id = $sth->last_insert_id( undef, 'public', 'groups', undef, { sequence => 'groups_id_seq' } );
        $sth->finish();
        push @!, "Can not insert $$data{'label'} into groups" unless $id;
    }

    # синхронизация реальных роутов в группах
    unless ( @! ) {
        $self->_all_groups();
    }

    return $id;
}

sub _get_list {
    my $self = shift;

    my ( $sql, $sth, $groups, $list );

    # получаем список групп
    $sql = 'SELECT id,label FROM "public"."user_data"';

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();

    $groups = $sth->fetchall_hashref( 'id' );
    $sth->finish();
    push @!, "couldn't get list of groups" unless $groups;

    return $groups;
}

sub _get_data {
    my ( $self, $id ) = @_;

    return unless $id;

    my ( $result, $row, $sql, $sth );

    $sql = 'SELECT * FROM "public"."user_data" WHERE "id" = :id';
    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->bind_param( ':id', $id );
    $sth->execute();
    $row = $sth->fetchrow_hashref();
    $sth->finish();
    
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
        $sql = 'UPDATE "public"."user_data" SET '.join( ', ', map { "\"$_\"=".$self->{'app'}->pg_dbh->quote( $$data{$_} ) } keys %$data ) . " WHERE \"id\"=" . $$data{'id'} . "returning id";
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->execute();
        $result = $sth->fetchrow_array();
        $sth->finish();

        push @!, "Error by update $$data{'label'}" if ! defined $result;
    }

    return $result;
}

1;