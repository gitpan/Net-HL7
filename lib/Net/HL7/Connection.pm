################################################################################
#
# File      : Connection.pm
# Author    : Duco Dokter
# Created   : Mon Nov 11 17:43:16 2002
# Version   : $Id: Connection.pm,v 1.2 2003/03/28 10:23:48 wyldebeast Exp $ 
# Copyright : D.A.Dokter
#
################################################################################

package Net::HL7::Connection;

use 5.004;
use strict;
#use warnings;
use Net::HL7::Response;
use IO::Socket;


=head1 NAME

Net::HL7::Connection - A HL7 connection

=head1 SYNOPSIS


use Net::HL7::Connection;
use Net::HL7::Request;

my $conn = new Net::HL7::Connection('localhost', 8089);

my $req = new Net::HL7::Request();

... set some request attributes

my $res = $conn->send($req);

$conn->close();


=head1 DESCRIPTION

The Net::HL7::Connection object represents the tcp connection to the
HL7 message broker. The Connection has only two useful methods (apart
from the constructor), send and close. The 'send' method takes a
Net::HL7::Request as argument, and returns a Net::HL7::Response. The
send method can be used more than once, before the connection is
closed.

=head1 FIELDS

The Connection object holds the following fields:

=over 4

=item MESSAGE_PREFIX

The prefix to be sent to the HL7 server to initiate the
message. Defaults to \013.

=item MESSAGE_SUFFIX

End of message signal for HL7 server. Defaults to \034\015.

=back

=cut

our $MESSAGE_PREFIX = "\013";
our $MESSAGE_SUFFIX = "\034\015";


=head1 METHODS

The following methods are available:

=over 4

=item B<$c = new Net::HL7::Connection( $host, $port )>

Creates a connection to a HL7 server, or returns undef when a
connection could not be established.are:

=cut

sub new {
    
    my $class = shift;
    bless my $self = {}, $class;
    
    $self->_init(@_) || return undef;
    
    return $self;
}


sub _init {

    my ($self, $host, $port) = @_;

    $self->{HANDLE} = $self->_connect($host, $port);
}


sub _connect {

    my ($self, $host, $port) = @_;

    my $remote = IO::Socket::INET->new
	(
	 Proto    => "tcp",
	 PeerAddr => $host,
	 PeerPort => $port,
	 timeout  => 10
	 )
	||
	return undef;
    
    return $remote;
}


=pod

=item B<$c-E<gt>send($request)>

Sends a Net::HL7::Connection object over this connection.

=cut

sub send {

    my ($self, $req) = @_;

    my $buff;
    my $handle = $self->{HANDLE};
    my $hl7Msg = $req->toString();

    # Setting separators to HL7 defaults, so print and read operations
    # will do the whole message at once.
    #
    {
	local $/;

	$/ = $MESSAGE_SUFFIX;

	# Send message, prefixed with HL7 message start symbol(s)
	print $handle $MESSAGE_PREFIX . $hl7Msg . $MESSAGE_SUFFIX;
     
	# Read response in slurp mode
	$buff = <$handle>;
    }

    # Remove message prefix and suffix
    $buff =~ s/^$MESSAGE_PREFIX//;
    $buff =~ s/$MESSAGE_SUFFIX$//;

    return new Net::HL7::Response($buff);
}


=pod

=item B<$c-E<gt>close()>

Close the connection.

=cut

sub close {

    my $self = shift;

    $self->{HANDLE}->close();
}

1;


=pod

=back

=head1 AUTHOR

D.A.Dokter <dokter@wyldebeast-wunderliebe.com>

=head1 LICENSE

Copyright (c) 2002 D.A.Dokter. All rights reserved.  This program is
free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

=cut
