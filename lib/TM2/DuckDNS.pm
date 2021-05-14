package TM2::DuckDNS;

use strict;
use warnings;

=head1 NAME

TM2::DuckDNS - TempleScript extension

=cut

our $VERSION = '0.01';

=pod

=head1 SYNOPSIS

   # not to be used from Perl

=head1 DESCRIPTION

This ontological extension allows TempleScript applications to use the L<DuckDNS|www.duckdns.org> service
to provide a given FQDN with an IP.

The usual scenario is that an Internet site is only given a public IP address on a temporary basis
(I<dynamic IP>). To allow external servers to find and/or identify this site, B<from the inside of the site> you
can send a beacon HTTP signal to DuckDNS.org to update the IP address the signal is launched from:

=encoding utf-8

   %include file:duckdns.ts

   § isa ts:stream
   return
      <+ every 60 min                           # trigger on a regular basis
    | ( "my-subdomain-at-duckdns" )             # only the subdomain you registered before
    |->> duckdns:update ("124533-secret-duckdns-token-here")
    |->> io:write2log                           # logging is always a good idea

That should keep the FQDN uptodate:

   dig my-subdomain-at-duckdns.duckdns.at
   ...
   your.ip.he.re

=head1 AUTHOR

Robert Barta, C<< <rho at devc.at> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2021 Robert Barta.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of TM2::DuckDNS
