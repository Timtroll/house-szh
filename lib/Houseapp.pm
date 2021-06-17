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

    $r->get('/')             ->to('index#index');       #

    $auth->post('/add')          ->to('index#add');
    $auth->post('/edit')         ->to('index#edit');
    $auth->post('/save')         ->to('index#save');
    $auth->post('/toggle')       ->to('index#toggle');

    # роут на который происходит редирект, для вывода ошибок
    $r->any('/*')->to('index#error');

}

1;
