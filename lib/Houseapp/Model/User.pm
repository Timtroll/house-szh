package Houseapp::Model::User;

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
        $sql = 'INSERT INTO "public"."users" ( "login", "email", "status", "password" ) VALUES ( :login, :email, :status, :password )';
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':login', $$data{'login'} );
        $sth->bind_param( ':email', $$data{'email'} );
        $sth->bind_param( ':status', $$data{'status'} );
        $sth->bind_param( ':password', $$data{'password'} );
        $sth->execute();
        $sth->finish();

        $id = $sth->last_insert_id( undef, 'public', 'users', undef, { sequence => 'users_id_seq' } );
        $sth->finish();
        push @!, "Can not insert data into users" unless $id;
    }

    return $id;
}

sub _get_list {
    my $self = shift;

    my ( $sql, $sth, $users, $list );

    # получаем список групп
    $sql = 'SELECT id,label FROM "public"."users"';

    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->execute();

    $users = $sth->fetchall_hashref( 'id' );
    $sth->finish();
    push @!, "couldn't get list of users" unless $users;

    return $users;
}

sub _get_user {
    my ( $self, $id ) = @_;

    return unless $id;

    my ( $result, $row, $sql, $sth );

    $sql = 'SELECT * FROM "public"."users" WHERE "id" = :id';
    $sth = $self->{app}->pg_dbh->prepare( $sql );
    $sth->bind_param( ':id', $id );
    $sth->execute();
    $row = $sth->fetchrow_hashref();
    $sth->finish();
    
    return $row;
}

sub _update_users {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth, $result );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for update";
    }

    unless ( @! ) {
        $sql = 'UPDATE "public"."users" SET '.join( ', ', map { "\"$_\"=".$self->{'app'}->pg_dbh->quote( $$data{$_} ) } keys %$data ) . " WHERE \"id\"=" . $$data{'id'} . "returning id";
        $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        $sth->execute();
        $result = $sth->fetchrow_array();
        $sth->finish();

        push @!, "Error by update data" if ! defined $result;
    }

    return $result;
}

sub _exists_in_users {
    my ( $self, $login, $pass ) = @_;

    my ($sql, $sth, $row);

    if ( $login && $pass ) {
        # ищем пользователя
        $sql = q(SELECT "id" FROM "users"
            WHERE "login"  = :login AND "password"  = :password
            GROUP BY "id");

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':login', $login );
        $sth->bind_param( ':password', $pass);
        $sth->execute();
        $row = $sth->fetchall_hashref('id');
        $sth->finish();

        if ( ref($row) eq 'HASH' && keys %$row && !@! ) {
            if (keys %$row == 1) {
                $$row{$login}{'status'} = $$row{$login}{'publish'} ? 1 : 0;
                delete $$row{$login}{'publish'};
                return $$row{$login};
            }
            else {
                push @!, "Exists more then one user";
            }
        }
        else {
            push @!, "User not exists";
        }
    }
    else {
        push @!, "Empty login or password in 'users' table";
    }

    return 0;
}

sub _delete {
    my ( $self, $data ) = @_;

    my ( $sql, $sth, $result );

    push @!, 'no id' unless $$data{'id'};

    unless( @! ) {
        # удаление записи из таблицы groups
        $sql = 'DELETE FROM "public"."users" WHERE "id" = :id';

        $sth = $self->{app}->pg_dbh->prepare( $sql );
        $sth->bind_param( ':id', $$data{'id'} );
        $result = $sth->execute();
        $sth->finish();

        push @!, "Could not delete User '$$data{'id'}'" if $result eq '0E0';
    }

    return $result;
}

1;