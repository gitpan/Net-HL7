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
use Config; $perl = $Config{'perlpath'};
use Net::HL7::Message;
use Net::HL7::Segment;

my $msg = new Net::HL7::Message();
my $seg1 = new Net::HL7::Segment("PID");

$seg1->setField(2, "Foo");
$msg->getSegmentByIndex(0)->setField(3, "XXX");

$msg->addSegment($seg1);

testEq(2, $msg->getSegmentByIndex(0)->getName(), "MSH");
testEq(3, $msg->getSegmentByIndex(1)->getName(), "PID");
testEq(4, $msg->getSegmentByIndex(0)->getField(3), "XXX");
testEq(5, $msg->getSegmentByIndex(1)->getField(2), "Foo");

$msg2 = new Net::HL7::Message("MSH|3|1\rPID|||xxx\r");

testEq(6, $msg2->toString(), "MSH|3|1\rPID|||xxx\r");
testEq(7, $msg2->toString(1), "MSH|3|1\nPID|||xxx\n");
testEq(8, $msg2->getSegmentByIndex(0)->getField(2), "3");

$msg3 = new Net::HL7::Message("MSH*3*1\rPID***xxx\r");

testEq(9, $msg3->toString(), "MSH*3*1\rPID***xxx\r");
testEq(10, $msg3->toString(1), "MSH*3*1\nPID***xxx\n");
testEq(11, $msg3->getSegmentByIndex(0)->getField(2), "3");

