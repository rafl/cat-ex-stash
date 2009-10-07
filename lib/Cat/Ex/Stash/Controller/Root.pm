package Cat::Ex::Stash::Controller::Root;

use Moose;
BEGIN { extends 'Catalyst::Controller::ActionRole' }

__PACKAGE__->config(
    namespace    => '',
    action_roles => ['~StashManager'],
);

sub index : Path Args(0) Stashes(foo) {
    my ($self, $ctx) = @_;
    $ctx->stash(foo => 'bar');
    $ctx->response->body($ctx->stash->foo);
}

sub foo : Path('foo') Args(0) StashRole(~Foo) {
    my ($self, $ctx) = @_;

    $ctx->stash(
        foo => 'bar',
        baz => 42,
        moo => ['kooh'],
    );

    $ctx->response->body($ctx->stash->dump);
}

1;
