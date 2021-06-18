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
    $vfields = $self->_param_fields();


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

    $r->get('/')                 ->to('index#index');       #
    $r->get('/list')             ->to('user#list');       #

    $auth->post('/user/add')          ->to('user#add');
    $auth->post('/user/edit')         ->to('user#edit');
    $auth->post('/user/save')         ->to('user#save');
    $auth->post('/user/toggle')       ->to('user#toggle');

    $auth->post('/data/add')          ->to('data#add');
    $auth->post('/data/edit')         ->to('data#edit');
    $auth->post('/data/save')         ->to('data#save');
    $auth->post('/data/toggle')       ->to('data#toggle');

    $auth->post('/document/add')          ->to('document#add');
    $auth->post('/document/edit')         ->to('document#edit');
    $auth->post('/document/save')         ->to('document#save');
    $auth->post('/document/toggle')       ->to('document#toggle');


    # роут на который происходит редирект, для вывода ошибок
    $r->any('/*')->to('index#error');

}

1;
