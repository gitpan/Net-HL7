################################################################################
#
# File      : Message.pm
# Author    : Duco Dokter
# Created   : Mon Nov 11 17:37:11 2002
# Version   : $Id: Message.pm,v 1.1.1.1 2003/03/25 13:12:08 wyldebeast Exp $ 
# Copyright : D.A.Dokter, Wyldebeast & Wunderliebe
#
################################################################################

package Net::HL7::Message;

use 5.004;
use strict;
use warnings;
use Net::HL7::Segment;

our $SEGMENT_SEPARATOR = "\015";

=pod

=head1 NAME

Net::HL7::Message


=head1 SYNOPSIS

my $request = new Net::HL7::Request();
my $conn = new Net::HL7::Connection('localhost', 8089);

my $seg1 = new Net::HL7::Segment("MSH");

$seg1->setField(1, "^~\\&");

$request->addSegment($seg1);

my $response = $conn->send($request);


=head1 DESCRIPTION

In general one needn't create an instance of the Net::HL7::Message
class directly, but use the L<Net::HL7::Request> class.

=head1 METHODS

=head2 B<$m = new Net::HL7::Message()>

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
	    
	    $segment =~ /^([A-Z0-9]{3})/;

	    my $hdr = $1;
	    my $i   = 0;

	    my $seg = new Net::HL7::Segment($hdr);

	    $seg || return 0;

	    foreach (split("\\" . $Net::HL7::Segment::FIELD_SEPARATOR, $segment)) {
		$seg->setField($i++, $_);
	    }

	    $self->addSegment($seg);
	}
    }

    $self->{ERR} = "";

    return 1;
}


=head 2 addSegment($segment, $index)

Set the segment at index to segment. The segment should be an instance of 
L<Net::HL7::Segment>. If the idnex is not given, the segment is added to
the end of the message.
=cut
sub addSegment { 

    my ($self, $segment, $idx) = @_;

    $idx || ($idx = @{ $self->{ORDER} });

    $self->{ORDER}->[$idx] = $segment->getName(0);
    $self->{SEGMENTS}->{ $segment->getName(0) } = $segment;
}


=head2 getSegmentByName($segment)

Return the segment specified by $segment.
=cut 
sub getSegmentByName {

    my ($self, $segment) = @_;

    return $self->{SEGMENTS}->{$segment};
}


=head2 getSegmentByIndex($index)

Return the segment specified by $index.

=cut 
sub getSegmentByIndex {

    my ($self, $index) = @_;

    return $self->{SEGMENTS}->{ $self->{ORDER}->[$index]};
}


=head2 toString($pretty)

Return a string representation of this message. This can be used to
send over a L<Net::HL7::Connection>. To print to other output, use
provide the $pretty argument as some true value. This will skip the
HL7 control characters.

=cut
sub toString {
    
    my ($self, $pretty) = @_;
    my $msg = "";

    foreach my $key (@{ $self->{ORDER} }) {
	
	$msg .= $self->{SEGMENTS}->{$key}->toString();
	$pretty ? ($msg .= "\n") : ($msg .= $SEGMENT_SEPARATOR);
    }

    return $msg;
}

1;

=pod

=head1 DESCRIPTION

The HL7::Message represents both the request and the answer to and
from the HL7 broker.  The message can be constructed in two ways:
based on a message template, and based on setting individual segment
values. The first method goes like this:

my $msg = new HL7::Message();

my $tpl = "
MSH|^~\&|ME|SYSTEM|YOU|TDM|${sysdate;%14s}||DFT^P03|${id;%16s}|P|2.4|||AL|NE|
EVN||${sysdate;%14s}|
";

$msg->useTemplate($tpl);

my $now = strftime "%Y%m%d%H%M%S", localtime;
my $ext = rand(1);
$ext =~ s/^0\.([0-9]{5}).*$/\.$1/;

$msg->setTemplateField("sysdate", $now
$msg->setTemplateField("id", "$now$ext");
 ...

The template contains slots in the following format:

${<name>;<format>}

Setting a value to a name with the C<setTemplateField> method will
replace the slot with the value formatted in the format specified, so
for instance C<${pipo;%06s}> set with C<setTemplateField("pipo", "foo")>
would render '000foo'. See L<sprintf> for details.

The other way is to just create a new message (either with or without
an initial header) like so:

my $msg = new HL7::Message();

$msg->setField("MSH", 4, strftime("%Y%m%m%H%M%S", localtime));


Use the C<toString> method to see what the message looks like.


=head1 METHODS

=head2 setField($segment, $index, $value)

Set the indexed value of segment specified by the argument. If the segment
doesn't exist, it is created.  


=head2 getField($segment, $index)

Get the value at the specified index from segment.


=head2 toString()

Return the message as a string. The special HL7 segment terminators are
translated into end of line characters.


=head2 useTemplate($template)

Use a template for the message. The template is a string containing
field definitions like:

C<${name;format}>

The format is just like formatting strings used in C<printf>.

A message template could look something like this: 

MSH|^~\&|ME|SYSTEM|YOU|TDM|${sysdate;%14s}||DFT^P03|${id;%16s}|P|2.4|||AL|NE|
EVN||${sysdate;%14s}|
";


=head2 setTemplateField($field, $value)

Set the field specified by $field to $value. This only makes sense when
a template is used.


=head2 setTemplateFields(\%fields)

Set the fields specified by the keys of the hashref to the values.


=head1 AUTHOR

D.A.Dokter <dokter@wyldebeast-wunderliebe.com>

=head1 LICENSE

Copyright (c) 2002 D.A.Dokter. All rights reserved.  This program is
free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

=cut
