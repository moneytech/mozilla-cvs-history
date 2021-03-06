# -*- mode: cperl; c-basic-offset: 8; indent-tabs-mode: nil; -*-

=head1 COPYRIGHT

 # ***** BEGIN LICENSE BLOCK *****
 # Version: MPL 1.1
 #
 # The contents of this file are subject to the Mozilla Public License
 # Version 1.1 (the "License"); you may not use this file except in
 # compliance with the License. You may obtain a copy of the License
 # at http://www.mozilla.org/MPL/
 #
 # Software distributed under the License is distributed on an "AS IS"
 # basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
 # the License for the specific language governing rights and
 # limitations under the License.
 #
 # The Original Code is Litmus.
 #
 # The Initial Developer of the Original Code is
 # the Mozilla Corporation.
 # Portions created by the Initial Developer are Copyright (C) 2006
 # the Initial Developer. All Rights Reserved.
 #
 # Contributor(s):
 #   Chris Cooper <ccooper@deadsquid.com>
 #   Zach Lipton <zach@zachlipton.com>
 #
 # ***** END LICENSE BLOCK *****

=cut

package Litmus::DB::Session;

use strict;
use base 'Litmus::DBI';

use Date::Manip;

Litmus::DB::Session->table('sessions');

Litmus::DB::Session->columns(Primary => qw/session_id/);
Litmus::DB::Session->columns(All => qw/user_id sessioncookie expires/);
Litmus::DB::Session->columns(TEMP => qw //);

Litmus::DB::Session->has_a(user_id => "Litmus::DB::User");

# expire the current Session object 
sub makeExpire {
	my $self = shift;
	$self->delete();
}

# If your db sessions are timing out immediately after login,
# check the date formats being compared in isValid and the contents of the
# sessions table in the db.
sub isValid {
  my $self = shift;

  my $now = &getCurrentTimestamp();
  my $expiry = &formatDate($self->expires());

  if ($expiry <= $now) {
    $self->makeExpire();
    return 0;
  }

  if (!$self->user_id()->enabled() || $self->user_id()->enabled() == 0) {
    $self->makeExpire();
    return 0;
  }
  return 1;
}

# These functions will hopefully make it easier to change the date format that
# gets compared against the session expiry if the format should change, e.g.
# db change.
sub getCurrentTimestamp {
  return &Date::Manip::UnixDate("now","%q");
}

sub formatDate {
  my $date_to_format = shift;
  $date_to_format =~ s/^\w\w\w //;
  return &Date::Manip::UnixDate($date_to_format,"%q");
}

1;
