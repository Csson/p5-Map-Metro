use Map::Metro::Standard;

package Map::Metro::Emitter {

    use Moose;
    use Kavorka;
    use List::AllUtils 'none';
    use Types::Standard -types;

    use Module::Pluggable search_path => ['Map::Metro::Plugin::Hook'], require => 1, asdf => 'new';

    has wanted_hook_plugins => (
        is => 'ro',
        isa => ArrayRef[ Str ],
        traits => ['Array'],
        handles => {
            all_wanted_hook_plugins => 'elements',
        },
    );
    has registered_hooks => (
        is => 'rw',
        isa => ArrayRef,
        traits => ['Array'],
        handles => {
            add_registered => 'push',
            all_registered => 'elements',
            filter_registered => 'grep',
        },
    );

    sub BUILD {
        my $self = shift;

        PLUGIN:
        foreach my $pluginname ($self->plugins) {
            my $actual = $pluginname =~ s{^Map::Metro::Plugin::Hook::}{}r;
            next PLUGIN if none { $_ eq $actual } $self->all_wanted_hook_plugins;
            my $plugin = $pluginname->new;
            $self->register($plugin);
        }
    }
    method register($plugin) {
        my %hooks_list = $plugin->register;

        foreach my $event (keys %hooks_list) {
            my $hook = Map::Metro::Hook->new(event => $event, action => $hooks_list{ $event }, plugin => $plugin);
            $self->add_registered($hook);
        }
    }

    method routing_completed($routing) {
        $self->emit('routing_completed', $routing);
    }

    method emit($event, @args) {
        my @hooks = $self->filter_registered(sub { $_->event eq $event });

        foreach my $hook (@hooks) {
            $hook->action->($hook->plugin, @args);
        }
    }
}
