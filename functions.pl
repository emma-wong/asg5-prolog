% $Id: functions.pl,v 1.3 2016-11-08 15:04:13-08 - - $
% This program was completed using pair programming.
% Partners:
% Ryan Watkins (rdwatkin)
% Emma Wong (emgwong)

% -- Given function to calculate great circle distance --
haversine_radians( Lat1, Lon1, Lat2, Lon2, Distance ) :-
   Dlon is Lon2 - Lon1,
   Dlat is Lat2 - Lat1,
   A is sin( Dlat / 2 ) ** 2
      + cos( Lat1 ) * cos( Lat2 ) * sin( Dlon / 2 ) ** 2,
   Dist is 2 * atan2( sqrt( A ), sqrt( 1 - A )),
   Distance is Dist * 3961.

