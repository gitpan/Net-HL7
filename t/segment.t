# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN {
	$| = 1; 
	print "1..17\n";

	unshift(@INC, "./lib");
}

END {
	print "not ok 1\n" unless $loaded;
}

$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# util
sub test {
    local($^W) = 0;
    my($num, $true, $msg) = @_;
    print($true ? "ok $num\n" : "not ok $num: $msg\n");
}

require 5.004_05;
use Config; my $perl = $Config{'perlpath'};
use Net::HL7::Segment;

my $seg = new Net::HL7::Segment("MSH");
$seg->setField(0, "XXX");
$seg->setField(3, "XXX");

test(2, $seg->getField(0) eq "MSH", "Field 0 is " . $seg->getField(0) . ", 
	expected MSH"
);
test(3, $seg->getField(3) eq "XXX", "Field 3 is " . $seg->getField(3) . ", 
	expected XXX"
);
test(4, $seg->getFieldSeparator() eq "|", "Field separator not retrieved");

$seg->setFieldSeparator("*");
test(5, $seg->getFieldSeparator() eq "*", 
	"Field separator is " . $seg->getFieldSeparator() .", expected *");
$seg->setFieldSeparator("|");

test(6, $seg->getName() eq "MSH", "Name is " . $seg->getName() . ", expected MSH");

test(7, $seg->toString() eq "MSH|||XXX", 
	"Segment string is " . $seg->toString() . ", expected MSH|||XXX"
);

test(8, ! defined(new Net::HL7::Segment()), "Should be undef, was $seg");

test(9, ! defined( new Net::HL7::Segment("XXXX")), "Should be undef, was $seg");

test(10, ! defined(new Net::HL7::Segment("xxx")), "Should be undef, was $seg");

$seg = new Net::HL7::Segment("XXX");

$seg->setField(3, 1, 2, 3);

test(11, $seg->getField(3) eq "1^2^3", "Field should be 1^2^3");

$seg->setField(8, $Net::HL7::Segment::NULL);

test(12, $seg->getField(8) eq "\"\"", "NULL value not correctly set");

my @flds = $seg->getFields();

test(13, @flds == 9, "Length is " . @flds . ", should be 8");

@flds = $seg->getFields(2);

test(14, @flds == 7, "Length is " . @flds . ", should be 7");

@flds = $seg->getFields(2, 4);

test(15, @flds == 3, "Length is " . @flds . ", should be 3");

my $seg1 = new Net::HL7::Segment("DG1");

test(16, $seg1->getField(0) eq "DG1", "Field 0 is " . $seg1->getField(0) . ", 
	expected DG1"
);

$seg1->setField(12, "");

test(17, $seg1->size() == 12, "Size is " . $seg1->size() . ", expected 12");
