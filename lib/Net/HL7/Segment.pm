################################################################################
#
# File      : Segment.pm
# Author    : Duco Dokter
# Created   : Tue Mar  4 13:03:00 2003
# Version   : $Id: Segment.pm,v 1.7 2003/11/25 13:33:30 wyldebeast Exp $ 
# Copyright : Wyldebeast & Wunderliebe
#
################################################################################

package Net::HL7::Segment;

use 5.004;
use strict;
use Net::HL7::Segments::MSH;


our $FIELD_SEPARATOR = "|";
our $NULL = "\"\"";

=pod

=head1 NAME

Net::HL7::Segment


=head1 SYNOPSIS

my $seg = new Net::HL7::Segment("PID");

$seg->setField(3, "12345678");
print $seg->getField(1);

=head1 DESCRIPTION

The Net::HL7::Segment class represents segments of the HL7 message.

=head1 METHODS

=over 4

=item new($name)

Create an instance of this segment. The field separator defaults to
'|'. If the name is not given, no segment is created. The segment name
should be three characters long, and upper case. If it isn't, no
segment is created.

=cut
sub new {
    
    my $class = shift;
    bless my $self = {}, $class;
    
    $self->_init(@_) || return undef;
    
    return $self;
}


sub _init {
    
    my ($self, $name) = @_;

    ($name && (length($name) == 3)) || return undef;
    (uc($name) eq $name) || return undef;

    $self->{FIELDS} = [];

    $self->{FIELDS}->[0] = $name;
}


=pod

=item setField($index, @value)

Set the field specified by index to value. Indices start at 1, to stay
with the HL7 standard. Trying to set the value at index 0 has no
effect. If you provide more than one value, or an array of values, the
field will effectively be set to the join of these fields with the
Net::HL7::Segments::MSH::COMPONENT_SEPARATOR.  To set a field to the
HL7 null value, instead of omitting a field, can be achieved with the
Net::HL7::Segment::NULL variable, like:

  $segment->setField(8, $Net::HL7::Segment::NULL);

This will render the field as the double quote ("").

=cut
sub setField {

    my ($self, $index, @value) = @_;

    for (my $i = @{ $self->{FIELDS} }; $i < $index ; $i++) {
	$self->{FIELDS}->[$i] = "";
    }

    $index && ($self->{FIELDS}->[$index] = 
	       join($Net::HL7::Segments::MSH::COMPONENT_SEPARATOR, @value) );
}


=pod

=item getField($index)

Get the field at index. If the field is a composed field, you will
need to do something like:

@values = split($Net::HL7::Segments::MSH::REPETITION_SEPARATOR, $segment->getField(9));

=cut
sub getField {

    my ($self, $index) = @_;

    return $self->{FIELDS}->[$index];
}    


=pod

=item size()

Get the number of fields for this segment, not including the name

=cut
sub size {

    my $self = shift;

    return @{ $self->{FIELDS} } - 1;
}


=pod

=item getFields($from, $to)

Get the fields in the specified range.

=cut
sub getFields {

    my ($self, $from, $to) = @_;

    $from || ($from = 0);
    $to || ($to = $#{$self->{FIELDS}});

    return @{ $self->{FIELDS} }[$from..$to];
}    


=pod 

=item getName()

Get the name of the segment. This is basically the value at index 0

=cut
sub getName {

    my $self = shift;

    return $self->{FIELDS}->[0];
}


=pod

=item setFieldSeparator($sep)

Set the field separator for the segment

=cut
sub setFieldSeparator {

    my ($self, $sep) = @_;

    $FIELD_SEPARATOR = $sep;
}


=pod

=item getFieldSeparator()

Get the field separator for the segment

=cut
sub getFieldSeparator {

    my ($self) = @_;

    return $FIELD_SEPARATOR;
}


=pod

=item toString()

Return a string representation of this segment, based on the
L<Net::HL7::Segment::FIELD_SEPARATOR> variable. This method renders a
syntactically correct segment representation.

=back

=cut 
sub toString {

    my $self = shift;

    return join($FIELD_SEPARATOR, @{ $self->{FIELDS} });
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

