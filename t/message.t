# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN {
	$| = 1; 
	print "1..19\n";

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

sub testEqN {
    local($^W) = 0;
    my($num, $was, $expected) = @_;
    print(($expected = $was) ? "ok $num\n" : "not ok $num: Expected $expected, was $was\n");
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

$msg2 = new Net::HL7::Message("MSH|^~\\&|1\rPID|||xxx\r");

testEq(6, $msg2->toString(), "MSH|^~\\&|1\rPID|||xxx\r");
testEq(7, $msg2->toString(1), "MSH|^~\\&|1\nPID|||xxx\n");
testEq(8, $msg2->getSegmentByIndex(0)->getField(2), "^~\\&");

$msg3 = new Net::HL7::Message("MSH*^~\\&*1\rPID***xxx\r");

testEq(9, $msg3->toString(), "MSH*^~\\&*1\rPID***xxx\r");
testEq(10, $msg3->toString(1), "MSH*^~\\&*1\nPID***xxx\n");
testEq(11, $msg3->getSegmentByIndex(0)->getField(3), "1");

my $seg2 = new Net::HL7::Segment("XXX");

$msg3->addSegment($seg2);

$msg3->removeSegmentByIndex(1);

testEq(12, $msg3->getSegmentByIndex(1)->toString(1), $seg2->toString(1));

my $seg3 = new Net::HL7::Segment("YYY");
my $seg4 = new Net::HL7::Segment("ZZZ");

$msg3->insertSegment($seg3, 1);
$msg3->insertSegment($seg4, 1);

testEq(13, $msg3->getSegmentByIndex(3)->toString(1), $seg2->toString(1));

$msg3->removeSegmentByIndex(1);
$msg3->removeSegmentByIndex(1);

$msg3->removeSegmentByIndex(6);

my $seg5 = new Net::HL7::Segment("ZZ1");

# This shouldn't be possible
$msg3->insertSegment($seg5, 3);

testEq(14, $msg3->getSegmentByIndex(3), "");

$msg3->insertSegment($seg5, 2);

testEq(15, $msg3->getSegmentByIndex(2)->toString(1), $seg5->toString(1));

$msg3->setSegment($seg3, 2);

testEq(16, $msg3->getSegmentByIndex(2)->toString(1), $seg3->toString(1));

$msg3->setSegment($seg5);

testEq(17, $msg3->getSegmentByIndex(2)->toString(1), $seg3->toString(1));

testEqN(18, $msg3->getSegmentsByName("MSH"), 1);

$msh2 = new Net::HL7::Segments::MSH();

$msg3->addSegment($msh2);

testEqN(19, $msg3->getSegmentsByName("MSH"), 2);
