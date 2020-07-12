/* Fall 2018 STSCI 5060 Final Project */
/* Name: Nate Buchwald*/
/*NetID: nrb59*/

libname final 'C:\STSCI5060\Final';

libname myoracle oracle
user = 'Buchwald_Nate_STSCI5060FP' password = 'passw0rd' path = 'xe';

**Step 4;
proc sql;
	create table myoracle.School_Finance_2010_t as (
		Select * from final.School_Finance_2010
	);
quit;

**Step 12;
**B;
data myoracle.mfslr_t;
	set myoracle.mfr_v;
	set myoracle.msr_v;
	set myoracle.mlr_v;
run;

**Step 20;
proc sql;
	create table sasuser.Total_Rev as (
	Select * from myoracle.Total_Rev_v
	);
quit;

**Step 21;
proc corr data=sasuser.Total_Rev
	plots(maxpoints=NONE)=matrix(histogram);
	var tfedrev tstrev tlocrev;
run;

**Step 22;
proc reg data=sasuser.Total_Rev plots(maxpoints=NONE);
	model tfedrev=tstrev tlocrev;
run;

**Step 23;
proc corr data=myoracle.Total_Rev_v
	plots(maxpoints=NONE)=matrix(histogram);
	var tfedrev tstrev tlocrev;
run;

proc reg data=myoracle.Total_Rev_v plots(maxpoints=NONE);
	model tfedrev=tstrev tlocrev;
run;

**This is an example of in-database processing beacause SAS processes an oracle data table rather than a SAS data set;

**Step 24;
proc sql;
	create table myoracle.School_Finance_2014_t as(
	select * from final.School_Finance_2014
	);
quit;
