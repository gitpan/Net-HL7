# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN {
	$| = 1; 
	print "1..3\n";

	unshift(@INC, "./lib");
}

END {
	print "not ok 1\n" unless $loaded;
}

$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# util
sub testEq {
    local($^W) = 0;
    my($num, $was, $expected) = @_;
    print(($expected eq $was) ? "ok $num\n" : "not ok $num: Expected $expected, was $was\n");
}

require 5.004_05;
use Config; $perl = $Config{'perlpath'};
use Net::HL7::Message;
use Net::HL7::Connection;
use Net::HL7::Daemon;

my $msg = new Net::HL7::Message();
my $seg1 = new Net::HL7::Segment("PID");

$seg1->setField(3, "XXX");

$msg->addSegment($seg1);

my $d = new Net::HL7::Daemon(LocalPort => 12001);
my $clientMsg;

$pid = fork();

if ($pid) {

	while (my $client = $d->accept()) {
		$clientMsg = $client->getRequest()->toString(1);

		my $msh = $client->getRequest()->getSegmentByIndex(0);
		testEq(2, $msh->getField(2), "^~\\&");
		$client->sendAck();
		last;
	}

	exit;
} 

print "Trying to make connection\n";

$conn = new Net::HL7::Connection("localhost", 12001);

$conn || die "Couldn't connect";

$resp = $conn->send($msg);

$resp || die "No valid response";

$msh = $resp->getSegmentByIndex(0);

testEq(3, $msh->getField(9), "ACK");
