################################################################################
#
# File      : ACK.pm
# Author    : Duco Dokter
# Created   : Wed Mar 26 22:40:19 2003
# Version   : $Id: ACK.pm,v 1.5 2003/11/25 13:33:30 wyldebeast Exp $ 
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

=over 4

=cut

sub _init {

    my ($self, $req) = @_;

    $self->SUPER::_init($req->getSegmentByIndex(0)->toString(1));

    my $msa = new Net::HL7::Segment("MSA");
    my $reqMsh;

    $req && ($reqMsh = $req->getSegmentByIndex(0));

    # Determine acknowledge mode: normal or enhanced
    #
    if ($reqMsh && ($reqMsh->getField(15) || $reqMsh->getField(16))) {
	$self->{ACK_TYPE} = "E";
	$msa->setField(1, "CA");
    }
    else {
	$self->{ACK_TYPE} = "N";
	$msa->setField(1, "AA");
    }

    $self->addSegment($msa);

    my $msh = $self->getSegmentByIndex(0);

    $msh->setField(9, "ACK");

    # Construct an ACK based on the request
    if ($req) {

	$reqMsh || last;

	$msh->setField(3, $reqMsh->getField(5));
	$msh->setField(4, $reqMsh->getField(6));
	$msh->setField(5, $reqMsh->getField(3));
	$msh->setField(6, $reqMsh->getField(4));
	$msa->setField(2, $reqMsh->getField(10));
    }

    return 1;
}

=pod

=item $ack->setAckCode($code, [$msg])

Set the acknowledgement code for the acknowledgement. Code should be
one of: A, E, R. Codes can be prepended with C or A, denoting enhanced
or normal acknowledge mode. This denotes: accept, general error and
reject respectively. The ACK module will determine the right answer
mode (normal or enhanced) based upon the request, if not provided.
The message provided in $msg will be set in MSA 3.

=cut
sub setAckCode {

    my ($self, $code, $msg) = @_;

    my $mode = "A";

    # Determine acknowledge mode: normal or enhanced
    #
    if ($self->{ACK_TYPE} eq "E") {
	$mode = "C";
    }

    if (length($code) == 1) {
	$code = "$mode$code";
    }

    $self->getSegmentByIndex(1)->setField(1, $code);
    $msg && $self->getSegmentByIndex(1)->setField(3, $msg);
}


=pod 

=back

=head1 AUTHOR

D.A.Dokter <dokter@wyldebeast-wunderliebe.com>

=head1 LICENSE

Copyright (c) 2002 D.A.Dokter. All rights reserved.  This program is
free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

=cut

1;
