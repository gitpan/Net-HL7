# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN {
	$| = 1; 
	print "1..11\n";

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
use Config; my $perl = $Config{'perlpath'};
use Net::HL7::Message;
use Net::HL7::Segment;
use Net::HL7::Messages::ACK;


my $msg = new Net::HL7::Message();
my $msh = $msg->getSegmentByIndex(0);

my $ack = new Net::HL7::Messages::ACK($msg);

testEq(2, $ack->getSegmentByIndex(1)->getField(1), "CA");

$msh->setField(15, "");
$ack = new Net::HL7::Messages::ACK($msg);

testEq(3, $ack->getSegmentByIndex(1)->getField(1), "CA");

$msh->setField(16, "");
$ack = new Net::HL7::Messages::ACK($msg);

testEq(4, $ack->getSegmentByIndex(1)->getField(1), "AA");

$ack->setAckCode("E");

testEq(5, $ack->getSegmentByIndex(1)->getField(1), "AE");

$ack->setAckCode("CR");

testEq(6, $ack->getSegmentByIndex(1)->getField(1), "CR");

$ack->setAckCode("CR", "XX");

testEq(7, $ack->getSegmentByIndex(1)->getField(3), "XX");


$msg = new Net::HL7::Message();
$msh = $msg->getSegmentByIndex(0);

$msh->setField(16, "NE");
$msh->setField(11, "P");
$msh->setField(12, "2.4");
$msh->setField(15, "NE");

$ack = new Net::HL7::Messages::ACK($msg);


testEq(8, $ack->getSegmentByIndex(0)->getField(11), "P");

testEq(9, $ack->getSegmentByIndex(0)->getField(12), "2.4");

testEq(10, $ack->getSegmentByIndex(0)->getField(15), "NE");

testEq(11, $ack->getSegmentByIndex(0)->getField(16), "NE");
