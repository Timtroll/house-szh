package Houseapp::Helpers::PgGraph;

use strict;
use warnings;

use utf8;

use base 'Mojolicious::Plugin';

use DBD::Pg;
use DBI;

use Data::Dumper;
use common;

sub register {
    my ($self, $app) = @_;

    #################################
    # Helper for Postgress

    $app->helper( 'pg_dbh' => sub {
        my $self = shift;

        # если в конфиге установлен test = 1 - подключаемся к тестовой базе
        my $database = 'pg_main';
        $database = 'pg_main_test' if ($config->{'test'});
        unless ($dbh) {
warn "db connect\n";
            $dbh = DBI->connect(
                $config->{'databases'}->{$database}->{'dsn'},
                $config->{'databases'}->{$database}->{'username'},
                $config->{'databases'}->{$database}->{'password'},
                $config->{'databases'}->{$database}->{'options'}
            );
        }
        $self->{errstr} = sub {
            warn "Error received: $DBI::errstr\n";
        };

        return $dbh;
    });
}

1;