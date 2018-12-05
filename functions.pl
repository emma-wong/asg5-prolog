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
sumTimes(time(H_A,M_A), time(H_B,M_B), time(H_C,M_C)) :-
  H_T is H_A + H_B,
  M_T is M_A + M_B,
  adjustTime(H_T, M_T, H_C, M_C).

adjustTime(H1, M1, H2, M2) :-
    H2 is H1 + floor(M1 / 60),
    M2 is mod(M1, 60).

% -- given airport Get airport Latitude and Longitude in radians
getAirportLocation(Airport1, RetLat, RetLon) :-
	airport(Airport1, _, degmin(A1, O1), degmin(A2, O2)),
	dmsToRads(degmin(A1, O1), RetLat),
	dmsToRads(degmin(A2, O2), RetLon).

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
checkForOvernight( flight(Depart, Arrive, time(Hr, Min)) ) :-
	Hr < 24.

% -- ListPath, a modified version of provided code
listpath(Node, End, Outlist ) :-
	listpath(Node, End, time(0,0), [Node], Outlist).

listpath(Node, Node, _,_,_).

listpath(Node, End, Time, Tried, [flight(Node, Next, Dep)|List]) :-
	flight(Node, Next, Dep),
	validDelayTimes(Time, Dep),
	flightArrivalTime( flight(Node, Next, Dep), ArrivalTime),
	checkForOvernight( flight(Node, Next, Dep)),
	not( member(Next, Tried)),
	listpath(Next, End, ArrivalTime, [Next|Tried], List). 

% -- Recursive Print Function
writePath( [] ).

writePath( [ flight(Depart, Arrive, time(Hr, Min)) |List]  ) :-
	airport(Depart, DName, _,_),
	airport(Arrive, AName, _,_),
	format('depart  %s  %s', [Depart, DName]),
	format('%2d:%2d', [Hr, Min]),nl,
	flightArrivalTime( flight(Depart, Arrive, time(Hr, Min)), time(Hr1, Min1)),
	format('arrive  %s  %s', [Arrive, AName]),
	format('%2d:%2d', [Hr1, Min1]),nl,
	writePath(List).
	
% -- Edge Cases
fly( Depart, Depart ) :-
  !, fail.

fly( Depart, _) :-
  not(airport( Depart, _,_,_) ),
  !, fail.

fly( _, Arrive) :-
  not( airport( Arrive, _, _,_)),
  !, fail.

% -- Main Call
fly( Depart, Arrive ) :-
	listpath( Depart, Arrive, Outlist ), nl,
	writePath( Outlist), !.
	

