package Net::HL7::Daemon::Client;

use Net::HL7::Request;
use Net::HL7::Connection;
use IO::Socket;


sub new {

    my ($class, $conn) = @_;

    bless my $self= {}, $class;

    $self->{CONN} = $conn;

    {
	local $/ = $Net::HL7::Connection::MESSAGE_SUFFIX;

	my $buff = <$conn>;

	$buff =~ s/^$Net::HL7::Connection::MESSAGE_PREFIX//;
	$buff =~ s/$Net::HL7::Connection::MESSAGE_SUFFIX$//;

	$self->{MSG} = new Net::HL7::Request($buff);

	$self->{MSG} || return undef;
    }
    
    return $self;
}


sub getRequest {

    my $self = shift;

    return $self->{MSG};
}


sub sendAck {

    my $self = shift;

    my $conn = $self->{CONN};

    print $conn $Net::HL7::Connection::MESSAGE_PREFIX;
    print $conn "MSH|ACK";
    print $conn $Net::HL7::Connection::MESSAGE_SUFFIX;

    $self->{CONN}->close();
}


sub sendNack {

    my $self = shift;

    my $conn = $self->{CONN};

    print $conn $Net::HL7::Connection::MESSAGE_PREFIX;
    print $conn "MSH|NACK";
    print $conn $Net::HL7::Connection::MESSAGE_SUFFIX;

    $self->{CONN}->close();
}


package Net::HL7::Daemon;

use IO::Socket;

=pod
=head1 NAME

Net::HL7::Daemon - a simple HL7 server

=head1 SYNOPSIS

use Net::HL7::Daemon;

my $d = new Net::HL7::Daemon() || die;

while (my $c = $d->accept) {

    $c->close;
    undef($c);
}

=head1 DESCRIPTION

Instances of the I<Net:HL7::Daemon> class listen on a socket for
incoming requests. 
The accept() method will return when a connection from a client is
available. The returned value will be a reference
to a object of the I<Net::HL7::Daemon::Client> class. 

This daemon does not fork(2) for you.  Your application, i.e. the
user of the I<Net::HL7::Daemon> is reponsible for forking if that is
desirable.

=head1 METHODS

The I<Net::HL7::Daemon> class provides the following methods:

=head2 new([%args]) 

= $d = new(%args)

The constructor takes any parameters that can also be passed to
IO::Socket.

$d = new Net::HL7::Daemon(
    LocalPort => 12001,
    Listen    => 5
)

=cut

sub new {
    my ($class, %args) = @_;
    
    $args{Listen}   ||= SOMAXCONN;
    $args{Proto}      = "tcp";
    $args{LocalPort}||= 12001;
    $args{Reuse}      = 1;
    $args{Type}       = SOCK_STREAM;
	  
    bless my $self = {}, $class;
    
    $self->{SOCK} = IO::Socket::INET->new(%args) || return undef;

    return $self;
}


=head2 $c = $d->accept()

This method is the same as I<IO::Socket::accept> but returns an
I<Net::HL7::Daemon::Client> reference.  It returns undef if you
specify a timeout for the daemon and no connection is made within that
time.

=cut

sub accept {

    my $self = shift;

    my $conn = $self->{SOCK}->accept();

    return new Net::HL7::Daemon::Client($conn);
}


1;


=pod 
=head1 NAME

Net::HL7::Daemon::Client


=head1 SYNOPSIS

my $d = new Net::HL7::Daemon();

while (my $client = $d->accept()) {

    my $msg = $client->getRequest();
    $client->sendAck();
}


=head1 DESCRIPTION

The I<Net::HL7::Daemon::Client> class provides a handler for incoming
HL7 requests. The client holds the message that came in, if it was
valid HL7, and can be used to send either an acknowledgement, or an
error back to the caller.


=head1 METHODS

=head2 new()


=head2 getRequest()

Return a reference to a Net::HL7::Request object.

=cut
