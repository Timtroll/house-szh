package Houseapp;

use utf8;
use strict;
use warnings;

use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Config;
use Mojo::Log;
use Houseapp::Model; 

use common;
use Data::Dumper;

$| = 1;

# This method will run once at server start
sub startup {
    my $self = shift;

    my ( $host, $r, $auth );

    # load database config
    $config = $self->plugin(Config => { file => rel_file('./house.conf') });
    $log = Mojo::Log->new(path => $config->{'log'}, level => 'debug');

    # Configure the application
    $self->secrets($config->{secrets});
    $host = $config->{'host'};

    $self->plugin('Houseapp::Helpers::Utils');
    $self->plugin('Houseapp::Helpers::Validate');
    $self->plugin('Houseapp::Helpers::PgGraph');
    $vfields = $self->_param_fields();

    # init Pg connection
    $dbh = $self->pg_dbh();

    # подгружаем модель и создадим соответствующий хелпер для вызова модели + передадим ссылки на $self
    my $model = Houseapp::Model->new( app => $self );
    $self->helper(
        model => sub {
            my ($self, $model_name) = @_;
            return $model->get_model($model_name);
        }
    );

# $self->model('Basis')->_get_tree();

    # загрузка правил валидации
#    $self->plugin('Houseapp::Helpers::Validate');
#    $vfields = $self->_param_fields();
warn "+++++++++++";
    # Router
    $r = $self->routes;

    $r->post('/auth/login')               ->to('auth#login');
    $r->any('/auth/logout')               ->to('auth#logout');

    $auth = $r->under()->to('auth#check_token');

    $auth->post('/user/index')        ->to('user#index');
    $auth->post('/user/add')          ->to('user#add');
    $auth->get('/user/edit')          ->to('user#edit');
    $auth->post('/user/save')         ->to('user#save');
    $auth->get('/user/delete')        ->to('user#delete');
    $auth->get('/user/activate')      ->to('user#activate');
    $auth->get('/user/deactivate')    ->to('user#deactivate');

    # роут на который происходит редирект, для вывода ошибок
    $r->any('/*')->to('index#error');

}

1;
