/* Fall 2018 STSCI 5060 Final Project */
/* Name: Nate Buchwald*/
/*NetID: nrb59*/

--Step 3:
Update state_t
set stcode = concat('0', substr(stcode,1,1))
where cast(stcode as int) < 10;

select * from state_t where rownum < 10;

--Step 4:
Describe School_Finance_2010_t;
Select * from School_Finance_2010_t
where rownum <= 10;

--Step 5;
--A:
ALTER TABLE School_Finance_2010_t
MODIFY IDCENSUS varchar2(15);

--B:
ALTER TABLE School_Finance_2010_t
MODIFY NAME varchar2(60);

--Step 6:
ALTER TABLE School_Finance_2010_t RENAME COLUMN NAME TO SD_NAME;
ALTER TABLE School_Finance_2010_t RENAME COLUMN State TO STCODE;

--Step 7:
Create table fedrev_t as (Select idcensus, stcode, (c14+ c15+ c16+ c17+ c18+ c19+ b11+ c20+ c25+ c36+ b10+ b12+
b13) as fed_rev from school_finance_2010_t);

Create table Strev_t as(Select idcensus, stcode, (c01+ c04+ c05+ c06+ c07+ c08+ c09+ c10+ c11+ c12+ c13+ c24+ c35+ c38+ 
c39) as st_rev from school_finance_2010_t);

Create table Locrev_t as(Select idcensus, stcode, (t02+ t06+ t09+ t15+ t40+ t99+ d11+ d23+ a07+ a08+ a09+ a11+ a13+
a15+ a20+ a40+ u11+ u22+ u30+ u50+ u97) as loc_rev from school_finance_2010_t);

Create table School_t as(select idcensus, stcode, sd_name from school_finance_2010_t);

--Step 8:
--A:
ALTER TABLE State_t
ADD CONSTRAINT PK_State PRIMARY KEY (stcode);

--B:
ALTER TABLE Fedrev_t
ADD CONSTRAINT PK_Fedrev PRIMARY KEY (idcensus);
ALTER TABLE Strev_t
ADD CONSTRAINT PK_Strev PRIMARY KEY (idcensus);
ALTER TABLE Locrev_t
ADD CONSTRAINT PK_Locrev PRIMARY KEY (idcensus);
ALTER TABLE School_t
ADD CONSTRAINT PK_School PRIMARY KEY (idcensus);

--C:
ALTER TABLE Fedrev_t
ADD CONSTRAINT FK_FedSchool
FOREIGN KEY (idcensus) REFERENCES School_t(idcensus);
ALTER TABLE Strev_t
ADD CONSTRAINT FK_StSchool
FOREIGN KEY (idcensus) REFERENCES School_t(idcensus);
ALTER TABLE Locrev_t
ADD CONSTRAINT FK_LocSchool
FOREIGN KEY (idcensus) REFERENCES School_t(idcensus);

--D:
ALTER TABLE School_t
ADD CONSTRAINT FK_StateSchool
FOREIGN KEY (stcode) REFERENCES State_t(stcode);

--Step 10:
Select idcensus, stcode, fed_rev as fed_revenue from Fedrev_t
where fed_rev > 1000000;

Select idcensus, stcode, st_rev as state_revenue from Strev_t
where st_rev > 1000000;

Select idcensus, stcode, loc_rev as local_revenue from Locrev_t
where loc_rev > 1000000;

--Step 11:
Create view sd#_v as(select stcode, Count(Unique(SD_name)) as SD# from school_finance_2010_t
group by stcode
);

--A:
Select t.stcode, t.stabb, v.sd# From sd#_v v inner join state_t t on v.stcode = t.stcode
where v.sd# = (Select max(sd#) from sd#_v);

--B:
Select t.stcode, t.stabb, v.sd# From sd#_v v inner join state_t t on v.stcode = t.stcode
where v.sd# = (Select min(sd#) from sd#_v);

--Step 12:
--A:
Create view mfr_v as(Select stcode, max(fed_rev) as MAX_FED_REV from fedrev_t
group by stcode)
order by stcode;

Create view msr_v as(Select stcode, max(st_rev) as MAX_ST_REV from strev_t
group by stcode)
order by stcode;

Create view mlr_v as(Select stcode, max(loc_rev) as MAX_LOC_REV from locrev_t
group by stcode)
order by stcode;

--C:
Select v.*, s.stname as State_Name from mfslr_t v inner join State_t s on s.stcode = v.stcode;

--Step 13:
select ab.stcode as state_code, ab.state_name, ab.max_fed_rev, cd.sd_name from (Select v.*, s.stname as State_Name from mfslr_t v
inner join State_t s on s.stcode = v.stcode) ab
inner join (select qr.*, sf.sd_name from (select f.*, l.idcensus from mfr_v f inner join fedrev_t l on f.stcode = l.stcode
where (l.stcode = f.stcode and f.max_fed_rev = l.fed_rev)) qr inner join school_finance_2010_t sf on
qr.idcensus = sf.idcensus) cd on (ab.stcode = cd.stcode and ab.max_fed_rev = cd.max_fed_rev) order by max_fed_rev desc;

--Step 14:
Create view Total_Rev_v as (
select f.idcensus, f.stcode, f.fed_rev as tfedrev, s.st_rev as tstrev, l.loc_rev as tlocrev from
fedrev_t f inner join strev_t s on f.idcensus = s.idcensus inner join locrev_t l on f.idcensus = l.idcensus
);

--Step 15:
select * from (select tr.stcode, s.stname, tr.idcensus, (tfedrev + tstrev + tlocrev) as total_revenue, sf.sd_name
from Total_Rev_v tr inner join State_t s on tr.stcode = s.stcode
inner join school_finance_2010_t sf on tr.idcensus = sf.idcensus
order by total_revenue desc) where rownum <= 100;

--Step 16:
select sf.stcode, s.stname, sf.stexp from (select stcode, sum(TOTALEXP) as stexp from SCHOOL_FINANCE_2010_T group by stcode) sf
inner join state_t s on sf.stcode = s.stcode order by stexp desc;

--Step 17:
set heading off;
select cast(sum(TOTALEXP) as decimal) from SCHOOL_FINANCE_2010_T;
set heading on;

--Step 18:
--A:
Create view fed_contribution_v as(
select f.idcensus, f.stcode, sf.sd_name, round((f.fed_rev / sf.totalexp), 4) as fed_pcnt
from fedrev_t f inner join school_finance_2010_t sf on f.idcensus = sf.idcensus
where sf.totalexp > 0
);

select * from fed_contribution_v
where fed_pcnt > 1
order by fed_pcnt desc;

--B:
create view st_contribution_v as(
select f.idcensus, f.stcode, sf.sd_name, round((f.st_rev / sf.totalexp), 4) as st_pcnt
from strev_t f inner join school_finance_2010_t sf on f.idcensus = sf.idcensus
where sf.totalexp > 0
);

select * from st_contribution_v
where st_pcnt > 1
order by st_pcnt desc;

--C:
create view loc_contribution_v as(
select f.idcensus, f.stcode, sf.sd_name, round((f.loc_rev / sf.totalexp), 4) as loc_pcnt
from locrev_t f inner join school_finance_2010_t sf on f.idcensus = sf.idcensus
where sf.totalexp > 0
);

select * from loc_contribution_v
where loc_pcnt > 1
order by loc_pcnt desc;

--Step 19:
create view fsl_contribution_v as(
select f.idcensus, f.stcode, f.sd_name, (fed_pcnt + st_pcnt + loc_pcnt) as fsl_pcnt
from fed_contribution_v f inner join st_contribution_v s on f.idcensus = s.idcensus
inner join loc_contribution_v l on f.idcensus = l.idcensus
);

--A:
select * from fsl_contribution_v
where fsl_pcnt > 3
order by fsl_pcnt desc;

--B:
select * from fsl_contribution_v
where fsl_pcnt <= .3
order by fsl_pcnt desc;



