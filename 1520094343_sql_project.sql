/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
select name from Facilities where membercost > 0.01

/* Q2: How many facilities do not charge a fee to members? */
select count(name) from Facilities where membercost = 0.00

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
select facid, name, membercost, monthlymaintenance 
from Facilities where membercost > 0.01 and membercost < monthlymaintenance * 0.2

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
select * from Facilities where facid in (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
select name, monthlymaintenance, 
case when monthlymaintenance > 100 then 'expensive' else 'cheap' end as yup
from Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
select max(joindate), firstname, surname from Members where memid != 0

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
select distinct f.name, concat(m.firstname,' ', m.surname)  
from Members as m 
join Bookings as b on m.memid = b.memid 
join Facilities as f on b.facid = f.facid 
where name like 'Tennis Court%'

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
select f.name, concat(m.firstname, ' ', m.surname), f.membercost * b.slots as cost
from Bookings as b 
join Facilities as f on b.facid = f.facid 
join Members as m on b.memid = m.memid 
where f.membercost * b.slots > 30 and b.starttime like ('2012-09-14%') and b.memid != 0

union all

select f.name, concat(m.firstname, ' ', m.surname), f.guestcost * b.slots as cost
from Bookings as b 
join Facilities as f on b.facid = f.facid 
join Members as m on b.memid = m.memid 
where f.guestcost * b.slots > 30 and b.starttime like ('2012-09-14%') and b.memid = 0
order by cost desc

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select concat(sub.firstname, ' ', sub.surname), sub.name, sub.cost 
from (select f.name, m.firstname, m.surname, 
case when b.memid = 0
then f.guestcost * b.slots
else f.membercost * b.slots
end as cost
from Bookings as b
join Facilities f on b.facid = f.facid
join Members as m on b.memid = m.memid
)sub
where cost > 30
order by cost desc

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
select * from
(select f.name,
sum(case when b.memid = 0 then (b.slots * f.guestcost) else (b.slots * f.membercost) end) as rev
from Bookings as b 
join Facilities as f
on f.facid = b.facid 
and b.memid = 0
group by f.name) a 
where rev < 1000 
order by rev desc 