/* print_assignment/1

	Prototype: print_assignment([+Course,+Section,+TA])

	Description:
		Prints the course, section and TA in the form
		"<TA> is assigned to <Course>, Section <Section>"

 */
print_assignment([A, B, C]) :- write(C), write(' is assigned to '), 
	write(A), write(', Section '), write(B).

/* no_overlap/4

	Prototype: no_overlap(+A,+B,+C,+D)

	Description:
		Fails if the time slot A-B overlaps with C-D, otherwise succeeds

	Notes:
		If start or end times are the same, there is no overlap

 */
no_overlap(A, B, C, D) :- C < A, D =< A, !; A < C, B =< C.

/* no_conflict/6

	Prototype: no_conflict(+Aday,+Astart,+Astop,+Sday,+Sstart,+Sstop)

	Description:
		Fails if two time slots on the same day overlap, succeeds otherwise

 */
no_conflict(Aday,Astart,Astop,Sday,Sstart,Sstop) :- not(Aday = Sday), ! ; 
	Aday = Sday, no_overlap(Astart,Astop,Sstart,Sstop).

/* no_conflict_all_unavailable/4

	Prototype: no_conflict_all_unavailable(+Aday,+Astart,+Astop,+Unavailable_List)

	Description:
		Similar to no_conflict except recurses over entire unavailable list

 */
no_conflict_all_unavailable(_,_,_,[]) :- !.
no_conflict_all_unavailable(Aday,Astart,Astop,[[D,Start,Stop]|T]) :- 
	no_conflict(Aday,Astart,Astop,D,Start,Stop),
	no_conflict_all_unavailable(Aday,Astart,Astop,T).

/* assign/3

	Prototype: assign(+Aneed,+Aresource,-Partial_Assign)

	Description:
		Succeeds if given resource can TA given need, fails otherwise.

	Notes:
		Uses goal isInCap(+Capabilities,+Course_Name) to determine
		if given course name is in capabilities list.

 */
assign([CN,Sec,D,Ts,Tf],[SN,Cap,U],[PACN,PAS,PASN]) :-
	isInCap(Cap, CN), no_conflict_all_unavailable(D,Ts,Tf,U),
	PACN = CN,
	PAS = Sec,
	PASN = SN.

isInCap([],_) :- fail.
isInCap([CapH|CapT],Course_Name) :- CapH = Course_Name; isInCap(CapT, Course_Name).

/* course_solution/3

	Prototype: course_solution(+ANeed,+Resources,-Assignment)

	Description:
		Looks through entire resource list and determines if need can be
		satisfied. If so, partial assignment is made to Assignment.

	Notes:
		If no resource fits need, the Assignment is ['none', 'none', 'none'].
		Always succeeds.

 */
course_solution(_,[], ['none','none','none']).
course_solution(ANeed,[RH|RT],Assignment) :- assign(ANeed, RH, Assignment), ! ;
	course_solution(ANeed,RT,Assignment), !.

/* remove_student/3

	Prototype: remove_student(+StudentName,+Resources,-Revised_Resources)

	Description:
		Looks through entire resource list and removes the entry with the
		StudentName in it.

	Notes:
		If StudentName is 'none' no entry is removed.
		Always succeeds

 */
remove_student('none', R, R) :- !.
remove_student(SN, [[SN,_,_]|R], R) :- !.
remove_student(SN,[A|R],[A|RR]) :- remove_student(SN, R, RR).

/* overall_solution/3

	Prototype: overall_solution(+Needs, +Resources, -Solution)

	Description:
		For each need, the resource list is queried to determine if an
		assignment can be made. Thus giving the complete solution to the
		list of needs when given a list of resources

 */
overall_solution(_, [], []) :- !.
overall_solution([], _, []) :- !.
overall_solution([NH|NT], Resources, [SH|ST]) :-
	course_solution(NH, Resources, [CN,S,SN]),
	SH = [CN,S,SN],
	remove_student(SN, Resources, D), 
	overall_solution(NT, D, ST).


