################################################################################
#
# File      : Segment.pm
# Author    : Duco Dokter
# Created   : Tue Mar  4 13:03:00 2003
# Version   : $Id: MSH.pm,v 1.4 2003/10/03 07:37:40 wyldebeast Exp $ 
# Copyright : Wyldebeast & Wunderliebe
#
################################################################################

package Net::HL7::Segments::MSH;

use 5.004;
use strict;
use base qw(Net::HL7::Segment);

our $COMPONENT_SEPARATOR    = "^";
our $REPETITION_SEPARATOR   = "~";
our $ESCAPE_CHARACTER       = "\\";
our $SUBCOMPONENT_SEPARATOR = "&";

=pod

=head1 NAME

Net::HL7::Segments::MSH


=head1 SYNOPSIS

my $seg = new Net::HL7::Segments::MSH();

$seg->setField(9, "ADT^A24");
print $seg->getField(1);

=head1 DESCRIPTION

The Net::HL7::Segments::MSH is an implementation of the
L<Net::HL7::Segment> class. The segment is a bit different from other
segments, in that the first field is the field delimiter after the
segment name. Other fields thus start counting from 2!  The setting
for the field separator can be changed by the setField method on index
1. The MSH segment also contains the default settings for field 2,
COMPONENT_SEPARATOR, REPETITION_SEPARATOR, ESCAPE_CHARACTER and
SUBCOMPONENT_SEPARATOR. These fields default to ^, ~, \ and &
respectively.


=head1 METHODS

=over 3

=cut
sub _init {
    
    my ($self) = @_;
    $self->SUPER::_init("MSH");

    $self->setField(1, $Net::HL7::Segment::FIELD_SEPARATOR);
    $self->setField(2, "$COMPONENT_SEPARATOR$REPETITION_SEPARATOR$ESCAPE_CHARACTER$SUBCOMPONENT_SEPARATOR");

    return $self;
}


=pod

=item B<setField($index, $value)>

Set the field specified by index to value. Indices start at 1, to stay
with the HL7 standard. Trying to set the value at index 0 has no
effect. Setting the value on index 1, will effectively change the
value of L<Net::HL7::Segment::FIELD_SEPARATOR> for the remainder of
this process; setting the field on index 2 will change the values of
COMPONENT_SEPARATOR, REPETITION_SEPARATOR, ESCAPE_CHARACTER and
SUBCOMPONENT_SEPARATOR, if the string is of length 4.

=cut
sub setField {

    my ($self, $index, $value) = @_;

    if ($index == 1) {
	if (length($value) == 1) {
	    $Net::HL7::Segment::FIELD_SEPARATOR = $value;
	}
	else {
	    return;
	}

    }

    if ($index == 2) {
	if (length($value) == 4) {
	    $value =~ /(.)(.)(.)(.)/;

	    $COMPONENT_SEPARATOR    = $1;
	    $REPETITION_SEPARATOR   = $2;
	    $ESCAPE_CHARACTER       = $3;
	    $SUBCOMPONENT_SEPARATOR = $4;
	}
	else {
	    return;
	}
    }

    $self->SUPER::setField($index, $value);
}


=pod

=item B<toString()>

Return a string representation of this segment, based on the
L<Net::HL7::Segment::FIELD_SEPARATOR> variable.

=back

=cut 
sub toString {

    my $self = shift;
    
    return join($Net::HL7::Segment::FIELD_SEPARATOR, "MSH", $self->getFields(2));
}

1;


=head1 AUTHOR

D.A.Dokter <dokter@wyldebeast-wunderliebe.com>

=head1 LICENSE

Copyright (c) 2002 D.A.Dokter. All rights reserved.  This program is
free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

=cut

