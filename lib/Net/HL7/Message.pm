################################################################################
#
# File      : Message.pm
# Author    : Duco Dokter
# Created   : Mon Nov 11 17:37:11 2002
# Version   : $Id: Message.pm,v 1.9 2003/08/28 09:57:23 wyldebeast Exp $ 
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

=item B<$m = new Net::HL7::Message([$msg])>

The constructor takes an optional string argument that is a string
representation of a HL7 message. If the string representation is not a
valid HL7 message. according to the specifications, undef is returned
instead of a new instance.

=cut
sub new {
    
    my $class = shift;
    bless my $self = {}, $class;
    
    $self->_init(@_) || return 0;
    
    return $self;
}


sub _init {

    my ($self, $hl7str) = @_;

    # We store the segments both as array and as hash, to enable quick
    # lookup by index and name.
    #
    $self->{SEGMENTS} = [];
    $self->{SEGMENT_HASH} = {};

    # If an HL7 string is given to the constructor, parse it.
    if ($hl7str) {

	foreach my $segment (split("[\n\\$SEGMENT_SEPARATOR]", $hl7str)) {
	    
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

	$msh->setField(7, strftime($HL7_DATE_FORMAT, localtime));

	my $ext = rand(1);
        $ext =~ s/[^0-9]//g;
        $ext = "." . substr($ext, 1, 5);

	$msh->setField(10, $msh->getField(7) . $ext);
	$msh->setField(11, "P");
	$msh->setField(12, $HL7_VERSION);
	$msh->setField(15, "AL");
	$msh->setField(16, "NE");

	$self->addSegment($msh);
    }

    $self->{ERR} = "";

    return 1;
}



=pod

=item B<addSegment($segment)>

Add the segment. to the end of the message. The segment should be an
instance of L<Net::HL7::Segment>.

=cut
sub addSegment { 

    my ($self, $segment) = @_;

    push( @{ $self->{SEGMENTS} }, $segment);
}


=pod

=item B<insertSegment($segment, $idx)>

Insert the segment. The segment should be an instance of
L<Net::HL7::Segment>. If the index is not given, the segment is added
to the  of the message.

=cut
sub insertSegment {

    my ($self, $segment, $idx) = @_;

    (! defined $idx) && return;
    ($idx > @{ $self->{SEGMENTS} }) && return;

    if ($idx == 0) {
	unshift(@{ $self->{SEGMENTS} }, $segment);
    } elsif ($idx == @{ $self->{SEGMENTS} }) {
	push(@{ $self->{SEGMENTS} }, $segment);
    }
    else {
	@{ $self->{SEGMENTS} } = 
	    (@{ $self->{SEGMENTS} }[0..$idx-1],
	     $segment,
	     @{ $self->{SEGMENTS} }[$idx..@{ $self->{SEGMENTS} } -1]
	     );
    }
}


=pod 

=item B<getSegmentByIndex($index)>

Return the segment specified by $index.

=cut 
sub getSegmentByIndex {

    my ($self, $index) = @_;

    return $self->{SEGMENTS}->[$index];
}


=pod

=item B<getSegmentsByName($name)>

Return an array of all segments with the given name

=cut 
sub getSegmentsByName {

    my ($self, $name) = @_;

    my @segments = ();

    foreach (@{ $self->{SEGMENTS} }) {
	($_->getName() eq $name) && push(@segments, $_);
    }

    return @segments;
}


=pod 

=item B<removeSegmentByIndex($index)>

Remove the segment indexed by $index. If it doesn't exist, nothing
happens, if it does, all segments after this one will be moved one
index up.

=cut
sub removeSegmentByIndex {

    my ($self, $index) = @_;

    ($index < @{ $self->{SEGMENTS} }) && splice( @{ $self->{SEGMENTS} }, $index, 1);
}


=pod

=item B<setSegment($seg, $index)>

Set the segment on index. If index is out of range, or not provided,
do nothing.

=cut
sub setSegment {

    my ($self, $segment, $idx) = @_;

    (! defined $idx) && return;
    ($idx > @{ $self->{SEGMENTS} }) && return;    

    @{ $self->{SEGMENTS} }[$idx] = $segment;
}


=pod

=item B<getSegments()>

Return an array containing all segments in the right order.

=cut
sub getSegments {

    my $self = shift;

    return @{ $self->{SEGMENTS} };
}


=pod

=item B<toString([$pretty])>

Return a string representation of this message. This can be used to
send over a L<Net::HL7::Connection>. To print to other output, use
provide the $pretty argument as some true value. This will skip the
HL7 control characters, and use '\n' instead.

=back

=cut
sub toString {
    
    my ($self, $pretty) = @_;
    my $msg = "";

    foreach my $key (@{ $self->{SEGMENTS} }) {

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
