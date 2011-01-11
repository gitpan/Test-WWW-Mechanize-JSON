use strict;
use warnings;

package Test::WWW::Mechanize::JSON;

our $VERSION = 0.5;

use parent "Test::WWW::Mechanize";
use JSON::Any;

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

Tests that the last received resopnse body is valid JSON.

A default description of "Got JSON from $url"
or "Not JSON from $url"
is used if none if provided.

Returns the L<JSON|JSON> object, that you may perform
further tests upon it.

=cut

sub json_ok {
	my ($self, $desc) = @_;
	return $self->_json_ok( $desc, $self->content );
}


=head3 $mech->x_json_ok($desc)

As C<$mech->json_ok($desc)> but examines the C<x-json> header.

=cut

sub x_json_ok {
	my ($self, $desc) = @_;
	return $self->_json_ok( 
		$desc, 
		$self->response->headers->{'x-json'}
	);
}

sub json {
	my ($self, $text) = @_;
	$text ||= exists $self->response->headers->{'x-json'}?
		$self->response->headers->{'x-json'}
	:	$self->content;
	my $json = eval {
		JSON::Any->jsonToObj($text);
	};
	return $json;
}

=head2 any_json_ok( $desc )

Like the other JSON methods, but passes if the response
contained JSON in the content or C<x-json> header.

=cut

sub any_json_ok {
	my ($self, $desc) = @_;
	return $self->_json_ok( 
		$desc, 
		$self->json
	);
}	


sub _json_ok {
	my ($self, $desc, $text) = @_;
	my $json = $self->json( $text );

	if (not $desc){
		if (defined $json and ref $json eq 'HASH' and not $@){
			$desc = sprintf 'Got JSON from %s', $self->uri;
		}
		else {
			$desc = sprintf 'Not JSON from %s (%s)', $self->uri, $@;
		}
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
	return _diag_json( $self->content );
}

sub diag_x_json {
	my $self = shift;
	return _diag_json( 
		$self->response->headers->{'x-json'}
	);
}

sub _diag_json {
	my ($self, $text) = @_;
	eval {
		my $json = $self->json( $text );

		if (defined $json and ref $json eq 'HASH' and not $@){
			diag JSON::Any->objToJson;
		} else {
			warn "Er...";
		}
	};
	warn $@ if $@;
}

sub utf8 {
	return $_[0]->response->headers('content-type') =~ m{charset=\s*utf-8}? 1 : 0;
}

=head2 utf8_ok( $desc )

Passes if the last response contained a C<charset=utf-8> definition in its content-type header.

=cut

sub utf8_ok {
	my $self = shift;
	my $desc = shift || 'Has a utf-8 heaer';
	Test::Builder->new->ok( $self->utf8, $desc );
}

1;

=head1 AUTHOR AND COPYRIGHT

Copyright (C) Lee Goddard, 2009/2011.

Available under the same terms as Perl itself.

=cut

1;
