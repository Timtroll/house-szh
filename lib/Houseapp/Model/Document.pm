package Freee::Model::Document;

use Mojo::Base 'Houseapp::Model::Base';

use Data::Dumper;

use DBD::Pg;
use DBI;

use common;

sub _insert_document {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }

    unless ( @! ) {
        $sql = 'INSERT INTO "public"."groups" ( "name", "status" ) VALUES ( :name, :status )';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':name', $$data{'name'} );
        $sth->bind_param( ':status', $$data{'status'} );
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
    $sql = 'SELECT id,label FROM "public"."groups"';

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();

    $groups = $sth->fetchall_hashref( 'id' );
    $sth->finish();
    push @!, "couldn't get list of groups" unless $groups;

    return $groups;
}

sub _get_document {
    my ( $self, $id ) = @_;

    return unless $id;

    my ( $result, $row, $sql, $sth );

    $sql = 'SELECT * FROM "public"."settings" WHERE "id" = :id';
    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->bind_param( ':id', $id );
    $sth->execute();
    $row = $sth->fetchrow_hashref();
    $sth->finish();
    
    return $row;
}

1;