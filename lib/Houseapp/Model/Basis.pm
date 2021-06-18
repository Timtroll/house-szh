package Houseapp::Model::Basis;


use Mojo::Base 'Houseapp::Model::Base';

use Data::Dumper;

use Mojo::JSON qw( decode_json );

use common;

# добавление события
# my $id = $self->insert_event({
#     "comment",     => 'comment',         - комментарий
#     'time_start'   => '01-09-2020',      - дата начала события
#     'initial_id'   => 11,                - id руководителя
#     "status"       => 0 или 1,           - активен ли поток, обязательное поле
# });
# возвращается id записи    
sub _insert_event {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth, $result, $students );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for insert";
    }

    unless ( @! ) {
        # открываем транзакцию
        # $self->{'app'}->pg_dbh->begin_work;

        # $sql = 'INSERT INTO "public"."events" ( "initial_id", "time_start", "comment", "publish" ) VALUES ( :initial_id, :time_start, :comment, :publish )';
        # $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        # $sth->bind_param( ':initial_id', $$data{'initial_id'} );
        # $sth->bind_param( ':time_start', $$data{'time_start'} );
        # $sth->bind_param( ':comment', $$data{'comment'} );
        # $sth->bind_param( ':publish', ( $$data{'status'} ? 1 : 0 ) );
        # $sth->execute();
        # $sth->finish();

        # $id = $sth->last_insert_id( undef, 'public', 'events', undef, { sequence => 'events_id_seq' } );
        # $sth->finish();
        # unless ( $id ) {
        #     push @!, "Can not insert $$data{'name'} into streams";
        #     $self->{'app'}->pg_dbh->rollback;
        #     return;
        # }

        # unless ( @! ) {
        #     # добавление в universal_links
        #     $students = decode_json( $$data{'student_ids'} );

        #     foreach my $student_id ( @$students ) {
        #         $sql = 'INSERT INTO "public"."universal_links" ( "a_link_id", "a_link_type", "b_link_id", "b_link_type", "owner_id" ) VALUES ( :a_link_id, :a_link_type, :b_link_id, :b_link_type, :owner_id )';
        #         $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        #         $sth->bind_param( ':a_link_id', $id );
        #         $sth->bind_param( ':a_link_type', 7 );
        #         $sth->bind_param( ':b_link_id', $student_id );
        #         $sth->bind_param( ':b_link_type', 2 );
        #         $sth->bind_param( ':owner_id', $$data{'owner_id'} );
        #         $result = $sth->execute();
        #         $sth->finish();
        #         unless ( $result ) {
        #             push @!, "Can not insert student into universal_links";
        #             $self->{'app'}->pg_dbh->rollback;
        #             return;
        #         }
        #     }
        # }

        # # закрытие транзакции
        # $self->{'app'}->pg_dbh->commit;
    }

    return $id;
}

# удаление события
# my $true = $self->_delete_event( 99 );
# возвращается true/false
sub _delete_event {
    my ( $self, $data ) = @_;

    my ( $sql, $sth, $result );

    push @!, 'no id' unless $$data{'id'};

    unless( @! ) {

        # # открываем транзакцию
        # $self->{'app'}->pg_dbh->begin_work;

        # # удаление записи из таблицы streams
        # $sql = 'DELETE FROM "public"."events" WHERE "id" = :id';

        # $sth = $self->{app}->pg_dbh->prepare( $sql );
        # $sth->bind_param( ':id', $$data{'id'} );
        # $result = $sth->execute();
        # $sth->finish();

        # if ( $result eq '0E0' ) {
        #     push @!, "Could not delete Event '$$data{'id'}'";
        #     $self->{'app'}->pg_dbh->rollback;
        #     return;
        # }

        # # удаление записи из таблицы universal_links
        # $sql = 'DELETE FROM "public"."universal_links" WHERE "a_link_id" = :id';

        # $sth = $self->{app}->pg_dbh->prepare( $sql );
        # $sth->bind_param( ':id', $$data{'id'} );
        # $result = $sth->execute();
        # $sth->finish();

        # if ( $result eq '0E0' ) {
        #     push @!, "Could not delete universal_link '$$data{'id'}'";
        #     $self->{'app'}->pg_dbh->rollback;
        #     return;
        # }

        # # закрытие транзакции
        # $self->{'app'}->pg_dbh->commit;
    }

    return $result;
}

# читаем одно событие
# my $row = $self->_get_event( 99 );
# возвращается строка в виде объекта
sub _get_event {
    my ( $self, $data ) = @_;

    my ( $sql, $sth, $result, $students, @students );

    unless ( $$data{'id'} ) {
        push @!, 'No group id';
    }
    else {
        # # открываем транзакцию
        # $self->{'app'}->pg_dbh->begin_work;

        # # получить запись о событии из таблицы events
        # $sql = 'SELECT id, initial_id, time_start, comment, publish AS status FROM "public"."events" WHERE "id" = :id';

        # $sth = $self->{app}->pg_dbh->prepare( $sql );
        # $sth->bind_param( ':id', $$data{'id'} );
        # $sth->execute();
        # $result = $sth->fetchrow_hashref();
        # $sth->finish();
        # unless ( $result ) {
        #     push @!, "Could not get Event '$$data{'id'}'";
        #     $self->{'app'}->pg_dbh->rollback;
        #     return;
        # }

        # unless( @! ) {
        #     $sql = 'SELECT b_link_id FROM "public"."universal_links" WHERE "a_link_id" = :id AND "a_link_type" = 7';
        #     $sth = $self->{app}->pg_dbh->prepare( $sql );
        #     $sth->bind_param( ':id', $$data{'id'} );
        #     $sth->execute();
        #     $students = $sth->fetchall_hashref( 'b_link_id' );
        #     $sth->finish();
        # }

        # if ( $students ) {
        #     foreach (sort {$a <=> $b} keys %$students) {
        #         push @students, $_;
        #     }
        # }

        # $$result{'student_ids'} = \@students;

        # # закрытие транзакции
        # $self->{'app'}->pg_dbh->commit;
    }

    return $result;
}

# сохранить эвент
# $self->save( $data );
sub _update_event {
    my ( $self, $data ) = @_;

    my ( $id, $sql, $sth, $result, @fields, $students );

    # проверка входных данных
    unless ( ( ref($data) eq 'HASH' ) && scalar( keys %$data ) ) {
        push @!, "no data for update";
    }

    unless ( @! ) {

        # # открываем транзакцию
        # $self->{'app'}->pg_dbh->begin_work;

        # @fields = qw( id initial_id time_start comment publish );
        # $sql = 'UPDATE "public"."events" SET '.join( ', ', map { "\"$_\"=".$self->{'app'}->pg_dbh->quote( $$data{$_} ) } @fields ) . " WHERE \"id\"=" . $$data{'id'} . "returning id";
        # $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        # $sth->execute();
        # $result = $sth->fetchrow_array();
        # $sth->finish();

        # push @!, "Error by update $$data{'id'}" if ! defined $result;

        # unless ( @! ) {
        #     # удаление записи из таблицы universal_links
        #     $sql = 'DELETE FROM "public"."universal_links" WHERE "a_link_id" = :id';

        #     $sth = $self->{app}->pg_dbh->prepare( $sql );
        #     $sth->bind_param( ':id', $$data{'id'} );
        #     $result = $sth->execute();
        #     $sth->finish();

        #     if ( $result eq '0E0' ) {
        #         push @!, "Could not delete universal_link '$$data{'id'}'";
        #         $self->{'app'}->pg_dbh->rollback;
        #         return;
        #     }
        # }

        # unless ( @! ) {
        #     # добавление в universal_links
        #     $students = decode_json( $$data{'student_ids'} );

        #     foreach my $student_id ( @$students ) {
        #         $sql = 'INSERT INTO "public"."universal_links" ( "a_link_id", "a_link_type", "b_link_id", "b_link_type", "owner_id" ) VALUES ( :a_link_id, :a_link_type, :b_link_id, :b_link_type, :owner_id )';
        #         $sth = $self->{'app'}->pg_dbh->prepare( $sql );
        #         $sth->bind_param( ':a_link_id', $$data{'id'} );
        #         $sth->bind_param( ':a_link_type', 7 );
        #         $sth->bind_param( ':b_link_id', $student_id );
        #         $sth->bind_param( ':b_link_type', 2 );
        #         $sth->bind_param( ':owner_id', $$data{'owner_id'} );
        #         $result = $sth->execute();
        #         $sth->finish();
        #         unless ( $result ) {
        #             push @!, "Can not insert student into universal_links";
        #             $self->{'app'}->pg_dbh->rollback;
        #             return;
        #         }
        #     }
        # }

        # # закрытие транзакции
        # $self->{'app'}->pg_dbh->commit;
    }

    return $result;
}

# тестовое дерево с данными
# $self->_get_tree();
# sub _get_tree {
#     my ( $self, $data ) = @_;

#     my $list = {};

# warn Dumper($list);

#     return $base;
# }









# sub _exist_item {
#     my ( $self, $cache_type, $item ) = @_;

#     return 0 unless $cache_type;

#     return exists( $$cache_type{ $item } ) ? 1: 0;
# }

# sub _update_element {
#     my ( $self, $data ) = @_;

#     my $old_name = $$cache_id{ $$data{'id'} }{'name'};

#     if ( $old_name ne $$data{'name'} ) {

#         delete $$cache_name{ $old_name };

#         # добавляем новый ключ в хэш (так как имя меняется)
#         $$cache_name{ $$data{'name'} } = {
#             "id"       => $$data{'id'},
#             "parent"   => $$cache_id{ $$data{'id'} }{'parent'},
#             "children" => $$cache_id{ $$data{'id'} }{'children'},
#             "name"     => $$data{'name'},
#             "status"   => $$data{'status'}
#         };
#     }
#     else {
#         # меняем статус (не меняем имя, так как оно совпадает)
#         $$cache_name{ $$cache_id{ $$data{'id'} }{'name'} }{'status'} = $$data{'status'};
#     }

#     # добавление изменений в cache_id
#     $$cache_id{ $$data{'id'} }{'name'}   = $$data{'name'};
#     $$cache_id{ $$data{'id'} }{'status'} = $$data{'status'};

#     # добавление изменений в cache
#     foreach ( @$base ) {
#         if ( $$_{'id'} == $$data{'id'} ) {
#             $$_{'name'} = $$data{'name'};
#             $$_{'status'} = $$data{'status'};
#             last;
#         }
#     }

#     return;
# }

# sub _insert_element {
#     my ( $self, $data ) = @_;

#     # увеличиваем последний id кэша
#     $max_cache_id++;

#     $$cache_id{ $max_cache_id } = $$cache_name{ $$data{'name'} } = {
#         "id" => $max_cache_id,
#         "parent" => $$data{'parent'} ? $$data{'parent'} : 0,
#         "children" => [],
#         "name" => $$data{'name'},
#         "status" => $$data{'status'}
#     };

#     push @$cache, {
#         "id" => $max_cache_id,
#         "parent" => $$data{'parent'} ? $$data{'parent'} : 0,
#         "children" => [],
#         "name" => $$data{'name'},
#         "status" => $$data{'status'}
#     };

#     return;
# }

# sub _recursive_delete {
#     my ( $self, $id ) = @_;

#     foreach my $item ( @$base ) {
#         if ( $$item{'id'} == $id ) {
#             $$item{'status'} = $$cache_id{ $id }{'status'} = $$cache_name{ $$cache_id{ $id }{'name'} }{'status'} = 0;
#             foreach my $child ( @{$$item{'children'}} ) {
#                 $self->_recursive_delete( $child );
#             }
#         }
#     }

#     return;
# }

# sub _recursive_get {
#     my ( $self, $id ) = @_;

#     foreach my $item ( @$base ) {
#         if ( $$item{'id'} == $id ) {
#             $$cache_id{ $id } = $$cache_name{ $$item{'name'} } = $item;
#             push @{$cache}, $item;
#             foreach my $child ( @{$$item{'children'}} ) {
#                 $self->_recursive_get( $child );
#             }
#         }
#     }


#     return;
# }

1;
