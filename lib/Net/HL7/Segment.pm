################################################################################
#
# File      : Segment.pm
# Author    : Duco Dokter
# Created   : Tue Mar  4 13:03:00 2003
# Version   : $Id: Segment.pm,v 1.3 2003/04/04 10:50:57 wyldebeast Exp $ 
# Copyright : Wyldebeast & Wunderliebe
#
################################################################################

package Net::HL7::Segment;

use 5.004;
use strict;

our $FIELD_SEPARATOR = "|";

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
'|'. If the name is not given, no segment is created.

=cut
sub new {
    
    my $class = shift;
    bless my $self = {}, $class;
    
    $self->_init(@_) || return 0;
    
    return $self;
}


sub _init {
    
    my ($self, $name) = @_;

    $self->{FIELDS}->[0] = $name;

    return $name;
}


=item setField($index, $value)

Set the field specified by index to value. Indices start at 1, to stay
with the HL7 standard. Trying to set the value at index 0 has no
effect;

=cut
sub setField {

    my ($self, $index, $value) = @_;

    $index && ($self->{FIELDS}->[$index] = $value);
}



=item getField($index)

Get the field at index.

=cut
sub getField {

    my ($self, $index) = @_;

    return $self->{FIELDS}->[$index];
}    


=item getName()

Get the name of the segment. This is basically the value at index 0

=cut
sub getName {

    my $self = shift;

    return $self->{FIELDS}->[0];
}


=item setFieldSeparator($sep)

Set the field separator for the segment

=cut
sub setFieldSeparator {

    my ($self, $sep) = @_;

    $FIELD_SEPARATOR = $sep;
}


=item getFieldSeparator()

Get the field separator for the segment

=cut
sub getFieldSeparator {

    my ($self) = @_;

    return $FIELD_SEPARATOR;
}


=item toString()

Return a string representation of this segment, based on the
L<Net::HL7::Segment::FIELD_SEPARATOR> variable.  

=back

=cut 
sub toString {

    my $self = shift;
    
    return join($FIELD_SEPARATOR, @{ $self->{FIELDS} });
}

1;

=head1 AUTHOR

D.A.Dokter <dokter@wyldebeast-wunderliebe.com>

=head1 LICENSE

Copyright (c) 2002 D.A.Dokter. All rights reserved.  This program is
free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

=cut

