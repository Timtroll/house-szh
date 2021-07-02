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

    $auth->post('/user/index')        ->to('user#index');
    $auth->post('/user/add')          ->to('user#add');
    $auth->post('/user/edit')         ->to('user#edit');
    $auth->post('/user/save')         ->to('user#save');
    $auth->post('/user/delete')       ->to('user#delete');
    $auth->post('/user/activate')     ->to('user#activate');
    $auth->post('/user/deactivate')   ->to('user#deactivate');

    $auth->post('/user_data/index')        ->to('user_data#index');
    $auth->post('/user_data/add')          ->to('user_data#add');
    $auth->post('/user_data/edit')         ->to('user_data#edit');
    $auth->post('/user_data/save')         ->to('user_data#save');
    $auth->post('/user_data/delete')       ->to('user_data#delete');
    $auth->post('/user_data/activate')     ->to('user_data#activate');
    $auth->post('/user_data/deactivate')   ->to('user_data#deactivate');

    $auth->post('/user_doc/index')          ->to('user_doc#index');
    $auth->post('/user_doc/delete')         ->to('user_doc#delete');
    $auth->post('/user_doc/search')         ->to('user_doc#search');
    $auth->post('/user_doc/update')         ->to('user_doc#update');


    # роут на который происходит редирект, для вывода ошибок
    $r->any('/*')->to('index#error');

}

1;
