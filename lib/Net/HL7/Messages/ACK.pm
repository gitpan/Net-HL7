################################################################################
#
# File      : ACK.pm
# Author    : Duco Dokter
# Created   : Wed Mar 26 22:40:19 2003
# Version   : $Id: $ 
# Copyright : Wyldebeast & Wunderliebe
#
################################################################################


package Net::HL7::Messages::ACK;

use strict;
use warnings;
use Net::HL7::Message;
use base qw(Net::HL7::Message);


=pod

=head1 NAME

Net::HL7::Messages::ACK


=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut

sub _init {

    my ($self, $req) = @_;

    $self->SUPER::_init();

    my $msa = new Net::HL7::Segment("MSA");
    $msa->setField(1, "CA");

    $self->addSegment($msa);

    my $msh = $self->getSegmentByIndex(0);

    $msh->setField(8, "ACK");

    # Construct an ACK based on the request
    if ($req) {

	my $reqMsh = $req->getSegmentByIndex(0);

	$reqMsh || last;

	$msh->setField(2, $reqMsh->getField(4));
	$msh->setField(3, $reqMsh->getField(5));
	$msh->setField(4, $reqMsh->getField(2));
	$msh->setField(5, $reqMsh->getField(3));
	$msh->setField(9, $reqMsh->getField(9));
	$msa->setField(2, $reqMsh->getField(9));
    }

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
