################################################################################
#
# File      : Segment.pm
# Author    : Duco Dokter
# Created   : Tue Mar  4 13:03:00 2003
# Version   : $Id: Segment.pm,v 1.1.1.1 2003/03/25 13:12:09 wyldebeast Exp $ 
# Copyright : Wyldebeast & Wunderliebe
#
################################################################################

package Net::HL7::Segments::MSH;

use 5.004;
use strict;
use base qw(Net::HL7::Segment);


=pod

=head1 NAME

Net::HL7::MSH


=head1 SYNOPSIS

my $seg = new Net::HL7::MSH();

$seg->setField(1, "^~\&");
print $seg->getField(1);

=head1 DESCRIPTION

The Net::HL7::MSH is an implementation of the L<Net::HL7::Segment> class.


=head1 METHODS


=head2 new()

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

    $self->setField(1, "^~\\&");

    return $name;
}

1;

=head1 AUTHOR

D.A.Dokter <dokter@wyldebeast-wunderliebe.com>

=head1 LICENSE

Copyright (c) 2002 D.A.Dokter. All rights reserved.  This program is
free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

=cut

