################################################################################
#
# File      : Segment.pm
# Author    : Duco Dokter
# Created   : Tue Mar  4 13:03:00 2003
# Version   : $Id: MSH.pm,v 1.1 2003/04/04 10:50:57 wyldebeast Exp $ 
# Copyright : Wyldebeast & Wunderliebe
#
################################################################################

package Net::HL7::Segments::MSH;

use 5.004;
use strict;
use base qw(Net::HL7::Segment);


=pod

=head1 NAME

Net::HL7::Segments::MSH


=head1 SYNOPSIS

my $seg = new Net::HL7::Segments::MSH();

$seg->setField(2, "^~\&");
print $seg->getField(1);

=head1 DESCRIPTION

The Net::HL7::Segments::MSH is an implementation of the
L<Net::HL7::Segment> class. The segment is a bit different from other
segments, in that the first field is the field delimiter after the
segment name. Other fields thus start counting from 2!

=head1 METHODS

=over 3

=item new Net::HL7::Segments::MSH()

This constructor takes no arguments.

=cut
sub new {
    
    my $class = shift;
    bless my $self = {}, $class;
    
    $self->_init("MSH") || return 0;
    
    return $self;
}


sub _init {
    
    my ($self, $name) = @_;

    $self->{FIELDS}->[0] = $name;

    $self->setField(1, $Net::HL7::Segment::FIELD_SEPARATOR);
    $self->setField(2, "^~\\&");

    return $name;
}


=item setField($index, $value)

Set the field specified by index to value. Indices start at 1, to stay
with the HL7 standard. Trying to set the value at index 0 has no
effect. Setting the value on index 1, will effectively change the value
of L<Net::HL7::Segment::FIELD_SEPARATOR> for the remainder of this process.

=cut
sub setField {

    my ($self, $index, $value) = @_;

    if ($index == 1) {
	$Net::HL7::Segment::FIELD_SEPARATOR = $value;
    }

    $self->SUPER::setField($index, $value);
}


=item toString()

Return a string representation of this segment, based on the
L<Net::HL7::Segment::FIELD_SEPARATOR> variable.

=back

=cut 
sub toString {

    my $self = shift;

    my @list = @{ $self->{FIELDS} };

    splice(@list, 1, 1);

    return join($Net::HL7::Segment::FIELD_SEPARATOR, @list);
}

1;

=head1 AUTHOR

D.A.Dokter <dokter@wyldebeast-wunderliebe.com>

=head1 LICENSE

Copyright (c) 2002 D.A.Dokter. All rights reserved.  This program is
free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

=cut

