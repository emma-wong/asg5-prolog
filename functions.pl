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


% -- Degree-Minutes-Seconds to Radians
dmsToRads( degmin( Deg, Min ), RetVal) :-
	RetVal is ((Deg + Min/60) * pi) / 180.


% -- NOT in prolog
not( X ) :- X, !, fail.
not( _ ).

% -- add two times
sumTimes( time(h1, m1), time(h2, m2), time(retHr, retMin) ) :-
	retHr is h1+h2,
	retMin is m1+m2,
	% !(min > 60)
	retHr is retHr + floor(retMin / 60),
	retMin is mod(retMin, 60).

% -- given airport Get airport Latitude and Longitude in radians
getAirportLocation(Airport1, retLat, retLon) :-
	airport(Airport1, _, degmin(a1, o1), degmin(a2, o2)),
	dmsToRads(a1, o1, retLat),
	dmsToRads(a2, o2, retLon).

% -- returns length of flight between two airports in hours
flightTime( A1, A2, retVal) :-
	getAirportLocation(A1, Lat1, Long1),
	getAirportLocation(A2, Lat2, Long2),
	haversine_radians( Lat1, Long1, Lat2, Long2, Distance),
	retVal is Distance / 500.

