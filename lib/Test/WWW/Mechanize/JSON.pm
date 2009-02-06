use strict;
use warnings;

package Test::WWW::Mechanize::JSON;

our $VERSION = 0.1; # do { my @r = ( q$Revision: 15311 $ =~ /\d+/g ); sprintf "%d." . "%03d" x $#r, @r };

=head1 NAME

Test::WWW::Mechanize::JSON - Adds a JSON method to WWW::Mechanize::Test

=head1 DESCRIPTION

Extends L<Test::WWW::Mechanize|Test::WWW::Mechanize>
to test JSON responses are valid.

=head1 DEPENDENCIES

C<L<Test::WWW::Mechanize|Test::WWW::Mechanize>>,
C<L<JSON|JSON>>

=cut

use base "Test::WWW::Mechanize";
use JSON;

#
# Add a method to Test::WWW::Mechanize (a Test::Builder sub-class)
# to provide a json_ok test
#

=head1 METHODS: HTTP VERBS

=head2 $mech->json_ok($desc)

Tests that the last received resopnse is valid JSON.

A default description of "Got JSON from $url"
or "Not JSON from $url" is used if none if provided.

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


=head2 $mech->diag_json

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

=head1 AUTHOR AND COPYRIGHT

Copyright (C) Lee Goddard, 2009.

Available under the same terms as Perl itself.

=cut

1;
