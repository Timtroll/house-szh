package Freee::Model::User;

use Mojo::Base 'Houseapp::Model::Base';

use Data::Dumper;

use DBD::Pg;
use DBI;

use common;

sub _insert_user {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }

    unless ( @! ) {
        $sql = 'INSERT INTO "public"."users" ( "name", "surname", "status" ) VALUES ( :name, :surname, :status )';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':name', $$data{'label'} );
        $sth->bind_param( ':surname', $$data{'name'} );
        $sth->bind_param( ':status', $$data{'status'} );
        $sth->execute();
        $sth->finish();

        $id = $sth->last_insert_id( undef, 'public', 'groups', undef, { sequence => 'groups_id_seq' } );
        $sth->finish();
        push @!, "Can not insert $$data{'label'} into groups" unless $id;
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

1;