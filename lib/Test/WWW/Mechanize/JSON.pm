use strict;
use warnings;

package Test::WWW::Mechanize::JSON;

our $VERSION = 0.2;

use base "Test::WWW::Mechanize";
use JSON;

=head1 NAME

Test::WWW::Mechanize::JSON - add a JSON method to the super-class

=head1 SYNOPSIS

	use Test::More 'no_plan';
	use_ok("Test::WWW::Mechanize::JSON") or BAIL_OUT;
	my $MECH = Test::WWW::Mechanize::JSON->new(
		noproxy => 1,
		etc     => 'other-params-for-Test::WWW::Mechanize',
	);
	$MECH->get('http://example.com/json');
	my $json_as_perl = $MECH->json_ok or BAIL_OUT Dumper $MECH->response;
	$MECH->diag_json;

=head1 DESCRIPTION

Extends L<Test::WWW::Mechanize|Test::WWW::Mechanize>
to test the JSON script and JSON output.

=head2 METHODS: HTTP VERBS

=head3 $mech->json_ok($desc)

Tests that the last received resopnse is valid JSON.

A default description of "Got JSON from $url"
or "Not JSON from $url"
is used if none if provided.

Returns the L<JSON|JSON> object, that you may perform
further tests upon it.

=cut

sub json_ok {
	my $self = shift;
	my ($json, $desc);

	eval {
		$json = JSON::from_json(
			$self->content,
			{utf8 => 0}
		);
	};

	if (defined $json and ref $json eq 'HASH' and not $@){
		$desc = sprintf 'Got JSON from %s', $self->uri;
	}
	else {
		$desc = sprintf 'Not JSON from %s (%s)', $self->uri, $@;
	}

	Test::Builder->new->ok( $json, $desc );

	return $json || undef;
}


=head3 $mech->diag_json

Like L<diag|Test::More/diag>, but renders the JSON of the last request
with indentation.

=cut

sub diag_json {
	my $self = shift;
	eval {
		my $json = JSON::from_json(
			$self->content,
			{utf8 => 0}
		);

		if (defined $json and ref $json eq 'HASH' and not $@){
			my $j = JSON->new;
			print $j->pretty->encode( $json ),"\n";
		} else {
			warn "Er...";
		}
	};
	warn $@ if $@;
}

1;

=head1 AUTHOR AND COPYRIGHT

Copyright (C) Lee Goddard, 2009.

Available under the same terms as Perl itself.

=cut

1;
