################################################################################
#
# File      : Message.pm
# Author    : Duco Dokter
# Created   : Mon Nov 11 17:37:11 2002
# Version   : $Id: Message.pm,v 1.3 2003/03/31 07:47:22 wyldebeast Exp $ 
# Copyright : D.A.Dokter, Wyldebeast & Wunderliebe
#
################################################################################

package Net::HL7::Message;

use 5.004;
use strict;
use warnings;
use Net::HL7::Segment;
use Net::HL7::Segments::MSH;
use POSIX qw(strftime);

our $SEGMENT_SEPARATOR = "\015";
our $HL7_DATE_FORMAT   = "%Y%m%d%H%M%S";
our $HL7_VERSION       = "2.4";

=pod

=head1 NAME

Net::HL7::Message

=head1 SYNOPSIS

my $request = new Net::HL7::Request();
my $conn = new Net::HL7::Connection('localhost', 8089);

my $seg1 = new Net::HL7::Segment("PID");

$seg1->setField(1, "foo");

$request->addSegment($seg1);

my $response = $conn->send($request);


=head1 DESCRIPTION

In general one needn't create an instance of the Net::HL7::Message
class directly, but use the L<Net::HL7::Request> class.
The Message will be created with a MSH segment as it's first segment.

=head1 METHODS

=over 4

=item B<$m = new Net::HL7::Message()>

The constructor takes an optional string argument that is a string
representation of a HL7 message. This makes it easy for the
L<Net::HL7::Connection> object to return new HL7 messages from a
server.

=cut
sub new {
    
    my $class = shift;
    bless my $self = {}, $class;
    
    $self->_init(@_) || return 0;
    
    return $self;
}


sub _init {

    my ($self, $hl7str) = @_;

    $self->{ORDER} = [];
    $self->{SEGMENTS} = {};

    # If an HL7 string is given to the constructor, parse it.
    if ($hl7str) {

	foreach my $segment (split("\\" . $SEGMENT_SEPARATOR, $hl7str)) {
	    
	    $segment =~ /^([A-Z0-9]{3})(.)/;

	    my $hdr = $1;
	    my $sep = $2;
	    my $i   = 0;
	    my $seg;

	    # If it's the MSH segment (should be the first one), set field
	    # separator to first char after MSH, and set counter to start
	    # at 2
	    #
	    if ($hdr eq "MSH") {
		$i = 2;
		$seg = new Net::HL7::Segments::MSH();
		$seg->setField(1, $sep);

		$segment =~ s/^MSH.//;
	    }
	    else {
		$seg = new Net::HL7::Segment($hdr);
	    }

	    $seg || return 0;

	    foreach (split("\\" . $Net::HL7::Segment::FIELD_SEPARATOR, $segment)) {
		$seg->setField($i++, $_);
	    }

	    $self->addSegment($seg);
	}
    }
    else {
	my $msh = new Net::HL7::Segments::MSH();

	$msh->setField(6, strftime($HL7_DATE_FORMAT, localtime));

	my $ext = rand(1);
        $ext =~ s/[^0-9]//g;
        $ext = "." . substr($ext, 1, 5);

	$msh->setField(9, $msh->getField(6) . $ext);

	$msh->setField(11, $HL7_VERSION);
	$msh->setField(14, "NE");
	$msh->setField(15, "NE");

	$self->addSegment($msh);
    }

    $self->{ERR} = "";

    return 1;
}


=item addSegment($segment, $index)

Set the segment at index to segment. The segment should be an instance of 
L<Net::HL7::Segment>. If the idnex is not given, the segment is added to
the end of the message.

=cut
sub addSegment { 

    my ($self, $segment, $idx) = @_;

    $idx || ($idx = @{ $self->{ORDER} });

    $self->{ORDER}->[$idx] = $segment;
}


=item getSegmentByIndex($index)

Return the segment specified by $index.

=cut 
sub getSegmentByIndex {

    my ($self, $index) = @_;

    return $self->{ORDER}->[$index];
}


=item toString($pretty)

Return a string representation of this message. This can be used to
send over a L<Net::HL7::Connection>. To print to other output, use
provide the $pretty argument as some true value. This will skip the
HL7 control characters, and use '\n' instead.

=back

=cut
sub toString {
    
    my ($self, $pretty) = @_;
    my $msg = "";

    foreach my $key (@{ $self->{ORDER} }) {
	
	$msg .= $key->toString();
	$pretty ? ($msg .= "\n") : ($msg .= $SEGMENT_SEPARATOR);
    }

    return $msg;
}

1;

=pod

=head1 AUTHOR

D.A.Dokter <dokter@wyldebeast-wunderliebe.com>

=head1 LICENSE

Copyright (c) 2002 D.A.Dokter. All rights reserved.  This program is
free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

=cut
