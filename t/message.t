BEGIN {
	unshift(@INC, "./lib");
}

require 5.004_05;
use Config; my $perl = $Config{'perlpath'};
use Test::More tests => 28;
use_ok("Net::HL7::Message");
use_ok("Net::HL7::Segment");
use_ok("Net::HL7::Segments::MSH");

# Simple constructor
#
my $msg = new Net::HL7::Message();
my $seg1 = new Net::HL7::Segment("PID");

$seg1->setField(2, "Foo");

$msg->addSegment(new Net::HL7::Segments::MSH());
$msg->addSegment($seg1);

$msg->getSegmentByIndex(0)->setField(3, "XXX");

ok($msg->getSegmentByIndex(0)->getName() eq "MSH", "Segment 0 name MSH");
ok($msg->getSegmentByIndex(1)->getName() eq "PID", "Segment 1 name PID");
ok($msg->getSegmentByIndex(0)->getField(3) eq "XXX", "3d field of MSH");
ok($msg->getSegmentByIndex(1)->getField(2) eq "Foo", "2nd field of PID");

$msg = new Net::HL7::Message("MSH|^~\\&|1|\rPID|||xxx|\r");

ok($msg->toString() eq "MSH|^~\\&|1|\rPID|||xxx|\r", "String representation of message");

ok($msg->toString(1) eq "MSH|^~\\&|1|\nPID|||xxx|\n", "Pretty print representation of message");
ok($msg->getSegmentByIndex(0)->getField(2) eq "^~\\&", "Encoding characters (MSH(2))");

# Constructor with components and subcomponents
#
$msg = new Net::HL7::Message("MSH|^~\\&|1|\rPID|||xx^x&y&z^yy^zz|\r");

@comps = $msg->getSegmentByIndex(1)->getField(3);

ok($comps[0] eq "xx", "Composed field");
ok($comps[1]->[1] eq "y", "Subcomposed field");

# Trying different field separator
#
$msg = new Net::HL7::Message("MSH*^~\\&*1\rPID***xxx\r");

ok($msg->toString() eq "MSH*^~\\&*1*\rPID***xxx*\r", "String representation of message with * as field separator");

ok($msg->getSegmentByIndex(0)->getField(3) eq "1", "3d field of MSH");

# Trying different field sep and control chars
#
$msg = new Net::HL7::Message("MSH*.%#\@*1\rPID***x.x\@y\@z.z\r");

@comps = $msg->getSegmentByIndex(1)->getField(3);

ok($comps[0] eq "x", "Composed field with . as separator");
ok($comps[1]->[1] eq "y", "Subcomposed field with @ as separator");

# Faulty constuctor
#
ok(! defined(new Net::HL7::Message("MSH|^~\\&*1\rPID|||xxx\r")), "Field separator not repeated");

my $seg2 = new Net::HL7::Segment("XXX");

$msg->addSegment($seg2);

$msg->removeSegmentByIndex(1);

ok($msg->getSegmentByIndex(1)->getName() eq $seg2->getName(), "Add/remove segment");

my $seg3 = new Net::HL7::Segment("YYY");
my $seg4 = new Net::HL7::Segment("ZZZ");

$msg->insertSegment($seg3, 1);
$msg->insertSegment($seg4, 1);

ok($msg->getSegmentByIndex(3)->getName() eq $seg2->getName(), "Insert segment");

$msg->removeSegmentByIndex(1);
$msg->removeSegmentByIndex(1);
$msg->removeSegmentByIndex(6);

my $seg5 = new Net::HL7::Segment("ZZ1");

# This shouldn't be possible
$msg->insertSegment($seg5, 3);

ok(! $msg->getSegmentByIndex(3), "Erroneous insert");

$msg->insertSegment($seg5, 2);

ok($msg->getSegmentByIndex(2)->getName() eq $seg5->getName(), "Insert segment");

$msg->setSegment($seg3, 2);

ok($msg->getSegmentByIndex(2)->getName() eq $seg3->getName(), "Set segment");

$msg->setSegment($seg5);

ok($msg->getSegmentByIndex(2)->getName() eq $seg3->getName(), "Erroneous set segment");

ok($msg->getSegmentsByName("MSH") == 1, "Number of MSH segments");

$msh2 = new Net::HL7::Segments::MSH();

$msg->addSegment($msh2);

ok($msg->getSegmentsByName("MSH") == 2, "Added MSH segment, now two in message");


# Fumble 'round with ctrl chars
#
$msg = new Net::HL7::Message();

$msh = new Net::HL7::Segments::MSH([]);

$msh->setField(1, "*");
$msh->setField(2, "abcd");

$msg->addSegment($msh);
ok($msg->toString() eq "MSH*abcd*\r", "Creating separate MSH");

$msh->setField(1, "|");
$msh->setField(2, "^~\\&");

ok($msg->toString() eq "MSH|^~\\&|\r", "Change MSH after add");

$msh = new Net::HL7::Segments::MSH([]);

$msh->setField(1, "*");
$msh->setField(2, "abcd");
$msg->setSegment($msh, 0);

ok($msg->toString() eq "MSH*abcd*\r", "New MSH with setSegment");



