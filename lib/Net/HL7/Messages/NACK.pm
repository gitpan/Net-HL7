################################################################################
#
# File      : NACK.pm
# Author    : Duco Dokter
# Created   : Wed Mar 26 22:40:19 2003
# Version   : $Id: $ 
# Copyright : Wyldebeast & Wunderliebe
#
################################################################################


package Net::HL7::Messages::NACK;

use strict;
use warnings;
use Net::HL7::Messages::ACK;
use base qw(Net::HL7::Messages::ACK);

=pod

=head1 NAME

Net::HL7::Messages::NACK


=head1 SYNOPSIS

=head1 DESCRIPTION

Inherits from ACK, and just sets MSH(8) to 'NACK'

=cut

sub _init {

    my ($self) = @_;

    $self->{ORDER} = [];
    $self->{SEGMENTS} = {};
    $self->{ERR} = "";

    $self->addSegment("MSA");

    return 1;
}


=head1 AUTHOR

D.A.Dokter <dokter@wyldebeast-wunderliebe.com>

=head1 LICENSE

Copyright (c) 2002 D.A.Dokter. All rights reserved.  This program is
free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

=cut

1;
