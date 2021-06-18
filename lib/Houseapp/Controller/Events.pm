package Houseapp::Controller::Events;

use utf8;

use Mojo::Base 'Mojolicious::Controller';
use common;
use Data::Dumper;

# $self->index();
# sub index {
#     my $self = shift;
# warn 'index';

#     my ( $data, $list, $resp, $events );

#     # проверка данных
#     $data = $self->_check_fields();

#     unless ( @! ) {
#         $$data{'page'} = 1 unless $$data{'page'};
#         $$data{'offset'} = ( $$data{'page'} - 1 ) * $$data{'limit'};
#         $$data{'order'} = 'ASC' unless $$data{'order'};

#         # получаем список событий
#         $events = $self->model('Events')->_get_list( $data );
#         push @!, "Can not get event list" unless $events;

#         unless ( @! ) {
#             $list = {
#                 'settings' => {
#                     'editable' => 1,
#                     'massEdit' => 0,
#                     'page' => {
#                         'current_page' => $$data{'page'},
#                         'per_page'     => $$data{'limit'}
#                     },
#                     'removable' => 1,
#                     'sort' => {
#                         'name' => 'id',
#                         'order' => $$data{'order'}
#                     }
#                 }
#             };

#             $list->{'body'} = $events;
#         }
#     }

#     $resp->{'message'} = join("\n", @!) if @!;
#     $resp->{'status'} = @! ? 'fail' : 'ok';
#     $resp->{'list'} = $list unless @!;

#     @! = ();

#     $self->render( 'json' => $resp );
# }

# sub add {
#     my $self = shift;
# warn 'add';

#     my ( $data, $resp );

#     # проверка данных
#     $data = $self->_check_fields();

#     unless ( @! ) {
#         my ( $flag_parent, $flag_name );
#         foreach ( @$base ) {
#             if ( $$_{'id'} == $$data{'parent'} ) {
#                 $flag_parent = 1;
#             }
#             if ( $$_{'name'} eq $$data{'name'} ) {
#                 $flag_name = 1;
#             }
#             if ( $flag_parent && $flag_name ) {
#                 last;
#             }
#         }
#         unless ( $flag_parent ) {
#             push @!, "Could not find field '$$data{'parent'}'";
#         }
#         if ( $flag_name ) {
#             push @!, "name '$$data{'name'}' already used";
#         }
#     }

#     $resp->{'message'} = join("\n", @!) if @!;
#     $resp->{'status'} = @! ? 0 : 1;
#     $resp->{'id'} = 1 unless @!;

#     @! = ();

#     $self->render( 'json' => $resp );
# }

# sub set {
#     my $self = shift;
# warn 'set';

#     my ( $data, $resp );

#     # проверка данных
#     $data = $self->_check_fields();

#     unless ( @! ) {
#         my ( $flag_parent, $flag_name );
#         foreach ( @$base ) {
#             if ( $$_{'id'} == $$data{'id'} ) {
#                 $flag_parent = 1;
#             }
#             if ( $$_{'name'} eq $$data{'name'} ) {
#                 $flag_name = 1;
#             }
#             if ( $flag_parent && $flag_name ) {
#                 last;
#             }
#         }
#         unless ( $flag_parent ) {
#             push @!, "Could not find field '$$data{'parent'}'";
#         }
#         if ( $flag_name ) {
#             push @!, "name '$$data{'name'}' already used";
#         }
#     }

#     $resp->{'message'} = join("\n", @!) if @!;
#     $resp->{'status'} = @! ? 0 : 1;
#     $resp->{'id'} = 1 unless @!;

#     @! = ();

#     $self->render( 'json' => $resp );
# }

# sub delete {
#     my $self = shift;
# warn 'delete';

#     my ( $data, $resp );

#     # проверка данных
#     $data = $self->_check_fields();

#     unless ( @! ) {
#         unless ( $self->model('Basis')->_exist_item( $cache_id, $$data{'id'} ) ) {
#             push @!, "Could not delete field '$$data{'id'}'";
#         }
#     }

#     unless ( @! ) {
#         $self->model('Basis')->_recursive_delete( $$data{'id'} );
#         unshift @$queue, {'command' => 'delete', 'id' => $$data{'id'} };
#     }

#     $resp->{'message'} = join("\n", @!) if @!;
#     $resp->{'status'} = @! ? 0 : 1;
#     $resp->{'id'} = 1 unless @!;

#     @! = ();

#     $self->render( 'json' => $resp );
# }

# sub get {
#     my $self = shift;
# warn 'get';

#     my ( $data, $info, $resp );

#     # проверка данных
#     $data = $self->_check_fields();

#     unless ( @! ) {
#         unless ( $self->model('Basis')->_exist_item( $cache_id, $$data{'id'} ) ) {
#             push @!, "Could not get field '$$data{'id'}'";
#         }
#     }

#     unless ( @! ) {
#         $info = $$cache_id{ $$data{'id'} };
#     }

#     $resp->{'message'} = join("\n", @!) if @!;
#     $resp->{'status'} = @! ? 0 : 1;
#     $resp->{'data'} = $info unless @!;

#     @! = ();

#     $self->render( 'json' => $resp );
# }

# sub reset {
#     my $self = shift;
# warn 'reset';

#     my ( $resp );

#     # чистим кэш
#     $cache = [];
#     $cache_id = {};
#     $cache_name = {};

#     $resp->{'message'} = join("\n", @!) if @!;
#     $resp->{'status'} = @! ? 0 : 1;

#     @! = ();

#     $self->render( 'json' => $resp );
# }


# sub transfer {
#     my $self = shift;
# warn 'transfer';

#     my ( $resp );

#     $resp->{'message'} = join("\n", @!) if @!;
#     $resp->{'status'} = @! ? 0 : 1;

#     @! = ();

#     $self->render( 'json' => $resp );
# }

# sub get_tree {
#     my $self = shift;
# warn 'get_tree';

#     my ( $resp );

#     $resp->{'message'} = join("\n", @!) if @!;
#     $resp->{'status'} = @! ? 0 : 1;
#     $resp->{'data'} = $base;

#     @! = ();

#     $self->render( 'json' => $resp );
# }

1;