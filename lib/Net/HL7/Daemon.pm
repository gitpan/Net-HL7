package Net::HL7::Daemon;

use IO::Socket qw(AF_INET INADDR_ANY inet_ntoa);
use base qw(IO::Socket::INET);
use strict;


sub new
{
    my($class, %args) = @_;
    $args{Listen} ||= 5;
    $args{Proto}  ||= 'tcp';
    return $class->SUPER::new(%args);
}


=item $c = $d->accept([$pkg])

This method is the same as I<IO::Socket::accept> but returns an
I<Net::HL7::Daemon::Client> reference.  It returns undef if
you specify a timeout and no connection is made within that time.  In
a scalar context the returned value will be a reference to a object of
the I<Net::HL7::Daemon::Client> class which is another
I<IO::Socket::INET> subclass.  In a list context a two-element array
is returned containing the new I<Net::HL7::Daemon::Client> reference
and the peer address; the list will be empty upon failure.

=cut

sub accept
{
    my $self = shift;
    
    my ($sock, $peer) = $self->SUPER::accept("Net::HL7::Daemon::Client");
    if ($sock) {
        ${*$sock}{'hl7d'} = $self;
        return wantarray ? ($sock, $peer) : $sock;
    } else {
        return;
    }
}


=item $d->getHost()

Returns the host where this daemon can be reached

=cut

sub getHost
{
    my $self = shift;
    
    my $addr = $self->sockaddr;
    if (!$addr || $addr eq INADDR_ANY) {
 	require Sys::Hostname;
 	return lc(Sys::Hostname::hostname());
    }
    else {
	return gethostbyaddr($addr, AF_INET) || inet_ntoa($addr);
    }
}


=item $d->getPort()

Returns the port on which this daemon is listening

=cut

sub getPort {

    my $self = shift;

    return $self->sockport;
}


package Net::HL7::Daemon::Client;

use IO::Socket;
use base qw(IO::Socket::INET);
use Net::HL7::Request;
use Net::HL7::Messages::ACK;
use Net::HL7::Messages::NACK;
use Net::HL7::Connection;
use strict;


=pod 
=head1 NAME

=head1 DESCRIPTION

The I<Net::HL7::Daemon::Client> is also a I<IO::Socket::INET>
subclass. Instances of this class are returned by the accept() method
of I<Net::HL7::Daemon>.  The following additional methods are
provided:

=over 4

=item $c->getMessage()

Read data from the socket and turn it into an I<Net::HL7::Request>
object which is then returned.  It returns C<undef> if reading of the
request fails.  If it fails, then the I<Net::HL7::Daemon::Client>
object ($c) should be discarded, and you should not call this method
again.

=cut

sub getRequest
{
    my $self = shift;

    ${*self}{'MSG'} && return ${*self}{'MSG'};

    {
	local $/ = $Net::HL7::Connection::MESSAGE_SUFFIX;

	my $buff = <$self>;

	$buff =~ s/^$Net::HL7::Connection::MESSAGE_PREFIX//;
	$buff =~ s/$Net::HL7::Connection::MESSAGE_SUFFIX$//;

	${*self}{'MSG'} = new Net::HL7::Request($buff);

	${*self}{'MSG'} || return undef;
    }

    return ${*self}{'MSG'};
}


=item $c->sendAck()

Write a I<Net::HL7::Messages::ACK> object to the client as a response.

=cut

sub sendAck {

    my $self = shift;
    my $res  = shift;

    if (! ref $res) {
	$res = new Net::HL7::Messages::ACK($self->getRequest());
    }

    print $self $Net::HL7::Connection::MESSAGE_PREFIX;
    print $self $res->toString();
    print $self $Net::HL7::Connection::MESSAGE_SUFFIX;
}


=item $c->sendNack()

Write a I<Net::HL7::Messages::NACK> object to the client as a response.

=cut

sub sendNack {

    my $self = shift;
    my $res  = shift;

    if (! ref $res) {
	$res = new Net::HL7::Messages::ACK();
    }

    print $self $Net::HL7::Connection::MESSAGE_PREFIX;
    print $self $res->toString();
    print $self $Net::HL7::Connection::MESSAGE_SUFFIX;
}


=pod
=head1 SEE ALSO

RFC 2068

L<IO::Socket::INET>

=head1 COPYRIGHT

Copyright 2003, D.A.Dokter

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

1;
