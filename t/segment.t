# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN {
	$| = 1; 
	print "1..10\n";

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
use Config; $perl = $Config{'perlpath'};
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

$seg = new Net::HL7::Segment();

test(8, $seg == undef, "Segment should be undef");

$seg = new Net::HL7::Segment("XXXX");

test(9, $seg == undef, "Segment should be undef");

$seg = new Net::HL7::Segment("xxx");

test(10, $seg == undef, "Segment should be undef");

