package Freee::Model::Data;

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
        $sql = 'INSERT INTO "public"."groups" ( "login", "email", "phone", "password" ) VALUES ( :login, :email, :phone, :password )';
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

1;