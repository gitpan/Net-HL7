# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN {
	$| = 1; 
	print "1..4\n";

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
use Net::HL7::Segment;
use Net::HL7::Segments::MSH;

my $pid = new Net::HL7::Segment("PID");
$pid->setField(1, "Foo");
$pid->setField(3, "Bar");

my $msh = new Net::HL7::Segments::MSH();

$msh->setField(1, "*");

testEq(2, $pid->toString(1), "PID*Foo**Bar");
testEq(3, $msh->getField(1), "*");
testEq(4, $msh->toString(1), "MSH*^~\\&");
