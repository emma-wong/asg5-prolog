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
   Distance is Dist * 3959.


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

% -- returns length of flight between two airports
flightTime( A1, A2, time(RetHours, RetMinutes)) :-
	getAirportLocation(A1, Lat1, Long1),
	getAirportLocation(A2, Lat2, Long2),
	haversine_radians( Lat1, Long1, Lat2, Long2, Distance),
	TotalTime is Distance / 500,
	RetHours is floor(TotalTime),
	RetMinutes is floor((TotalTime-RetHours)*60).
	

% -- Given a flight return the arrival time
flightArrivalTime( flight(Depart, Arrive, time(Hr, Min)), ArrivalTime) :-
	flightTime(Depart, Arrive, FT),
	sumTimes( time(Hr, Min), FT, ArrivalTime).

% -- Given two times Check if t2 is atleast 30minutes after t1
validDelayTimes( time(H1, M1), time(H2, M2)) :-
	Minutes1 is M1 + H1 * 60,
	Minutes2 is M2 + H2 * 60,
	Minutes1 + 29 < Minutes2.

% -- There are no overnight trips
checkForOvernight( flight(Depart, Arrive, DepTime) ) :-
	flightArrivalTime( flight(Depart, Arrive, DepTime), flight(Hr, Min) ),
	Hr < 24.

% -- ListPath, a modified version of provided code
ListPath(Node, End, Outlist) :-
	ListPath(Node, End, time(0,0), [Node], Outlist).

ListPath(Node, Node, _,_,_).

ListPath(Node, End, Time, Tried, [flight(Node, Next, Dep)|List]) :-
	flight(Node, Next, Dep),
	validDelayTimes(Time, Dep),
	flightArrivalTime( flight(Node, Next, Dep), ArrivalTime),
	checkForOvernight( flight(Node, Next, Dep)),
	not( member(Next, Tried)),
	ListPath(Next, End, ArrivalTime, [Next|Tried], List). 

WritePath( [] ) :- nl.

WritePath( [Flight(Depart, Arrive, time(Hr, Min)) |List]  ) :-
	airport(Depart, DName, _,_),
	airport(Arrive, AName, _,_),
	format('depart  %s  %s', [Depart, DName]),
	format('%2d:%2d', [Hr, Min]),nl,
	flightArrivalTime( flight(Depart, Arrive, time(Hr, Min)), time(Hr1, Min1)),
	format('arrive  %s  %s', [Arrive, AName]),
	format('%2d:%2d', [Hr1, Min1]),nl,
	WritePath(List).
	
% -- Main Call (Still need to implement edge cases)
fly( Depart, Arrive ) :-
	ListPath(Depart, Arrive, Outlist), nl,
	WritePath(Outlist), !.
	

