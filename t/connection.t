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
my $seg1 = new Net::HL7::Segment("MSH");
my $seg2 = new Net::HL7::Segment("PID");

$seg1->setField(3, "XXX");
$seg2->setField(2, "Foo");

$msg->addSegment($seg1);
$msg->addSegment($seg2);

my $d = new Net::HL7::Daemon(Port => 12001);
my $clientMsg;

$pid = fork();

if ($pid) {

	while (my $client = $d->accept()) {
		$clientMsg = $client->getRequest()->toString(1);
		testEq(2, $clientMsg, "MSH|||XXX\nPID||Foo\n");
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

$resp->toString(1);

testEq(3, $resp->toString(1), "MSH|ACK\n");