package Cat::Ex::Stash::Context;

use Moose;
use namespace::autoclean;

# SO WRONG. app/ctx-split, plz. kthx!
extends 'Cat::Ex::Stash';

has 'stash' => (
    is => 'rw',
    default => sub { shift->new_stash },
);

around stash => sub {
    my $orig = shift;
    my $self = shift;
    my $stash = $self->$orig;

    if (@_) {
        my $new_stash = @_ > 1 ? {@_} : $_[0];
        confess 'stash takes a hash or hashref'
            unless ref $new_stash;

        for my $key (keys %$new_stash) {
            confess "strict stash $key"
                unless $stash->can($key);

            $stash->$key($new_stash->{$key});
        }
    }

    return $stash;
};

{
    use Moose::Util::TypeConstraints;

    my $tc = subtype as 'ClassName';
    coerce $tc, from 'Str', via { Class::MOP::load_class($_); $_ };

    has stash_class => (
        is      => 'ro',
        isa     => $tc,
        coerce  => 1,
        lazy    => 1,
        default => 'Cat::Ex::Stash::Stash',
    );
}

sub new_stash {
    my ($self) = @_;

    # i suppose at some point, and after some refactorings in core, we could
    # just ask the dispatcher or something to get information about what the
    # actions that are going to be dispatched to are going to do to the stash
    # and create a stash instance for exactly that. for now, we'll just return
    # an instance of a basically empty class and apply roles to it while we're
    # dispatching to get the action-specific behaviour.

    return $self->stash_class->new;
}

1;
