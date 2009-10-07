package Cat::Ex::Stash::ActionRole::StashManager;

use Moose::Role;
use String::RewritePrefix;
use namespace::autoclean -also => 'expand';

has stash_role => (
    is        => 'ro',
    writer    => '_set_stash_role',
    predicate => '_has_stash_role',
);

sub expand {
    my ($controller, @short_names) = @_;
    return map {
        Class::MOP::load_class($_); $_
    } String::RewritePrefix->rewrite({
        '+' => '',
        '~' => $controller->_application . '::StashRole::',
        ''  => 'Catalyst::StashRole::',
    }, @short_names);
}

sub _build_stash_role {
    my ($self, $controller) = @_;
    my ($stashes, $stash_roles) = map { $self->attributes->{$_} } qw/Stashes StashRole/;

    return 0 unless $stashes || $stash_roles;
    return 1 if $self->_has_stash_role;

    # FIXME: don't create that if we don't have $stashes
    my $role = Moose::Meta::Role->create_anon_role(
        ($stashes
            ? (attributes => {
                map { ($controller->path_prefix . '_' . $_ => {
                    # TODO: tc parsing
                    accessor  => $_,
                    predicate => "has_$_",
                    is        => 'rw'
                }) } @{ $stashes },
              })
            : ()),
        cache => 1,
    );

    # i guess stash roles should somehow be parameterized so we can prefix the
    # slots like we do for :Stashes
    $role = Moose::Meta::Role->combine(
        map { [$_] }
            $role->name,
            expand($controller, @{ $stash_roles })
    ) if $stash_roles;

    $self->_set_stash_role($role);

    return 1;
}

around execute => sub {
    my ($orig, $self, $controller, $ctx, @args) = @_;

    if ($self->_build_stash_role($controller)) {
        $self->stash_role->apply($ctx->stash);
    }

    $self->$orig($controller, $ctx, @args);
};

1;
