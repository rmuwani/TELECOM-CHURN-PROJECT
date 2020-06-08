
/*import the data as csv file*/

LIBNAME MUW "C:\Users\Admin\Desktop\SAS PROJECT";


PROC IMPORT OUT= MUW.SAS_PROJECT 
            DATAFILE= "C:\Users\Admin\Desktop\SAS PROJECT\Project Data F
iles\Telco Churn Data.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

/*scan for duplicates and remove them*/

Proc sort data=MUW.SAS_PROJECT  out=MUW.Telcom_data nodupkey;  */sort data and scan for duplicates/*;
by CustomerID;
run;
/*summary data*/

PROC CONTENTS DATA=MUW.Telcom_data;
RUN;
 
/*data type*/

PROC CONTENTS DATA=MUW.Telcom_data varnum short;
RUN;
/*scan for missing data under var CHURN*/

/*DESCRIPTIVE ANALYSIS-CHURN*/

PROC FORMAT;
VALUE $CHAR " "="MISSING"
			OTHER= "NOT MISSING"
RUN;
/* 28.15 missing, label as missing*/
/*label as missing*/

PROC FREQ DATA=MUW.Telcom_data;
TABLE Churn/MISSING;
FORMAT _CHARACTER_$CHAR.;
RUN;

/*delete missing data on key column-Churn*/

data MUW.Telcom;
set MUW.Telcom_data;
if Churn eq"NA" then delete;
run;

/*descriptive Analysis-Barchart for Churn status; */

proc sgplot data=MUW.Telcom;
   Vbar Churn / datalabel  colormodel=twocolorramp;
   keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
    title"BarChart- Churn Status Analysis (ex_missing";
run;
/*analysis of churn with missing data*/

proc sgplot data=MUW.Telcom_data;
   vbar Churn / datalabel colormodel=twocolorramp;
    title"BarChart- Churn Status Analysis(inc_missing";
run;


*UNIVARIATE ANALYSIS*;

/*scan for missing monthinservice Analysis*/

proc means data=MUW.Telcom N NMISS MIN MEAN STD MAX;
var MonthsInService;
run;

*NO MISSING UNDER MONTHINSERVICE;
ods pdf file ="C:\Users\Admin\Desktop\SAS PROJECT\monthinservice_graph_1" style= MoonFlower notoc ;
TITLE "Month in Service Tren Analysis-Deactivation rate";
proc sgpanel data = MUW.Telcom;  
panelby Churn / columns = 2;  
histogram MonthsInService;  
density MonthsInService;  density MonthsInService/ type = kernel;  
colaxis label = 'Month in service';  
run;
ods pdf close;


/*scan for missing MONTHLY REVENUE*/
TITLE "Missing month in revenue values";
proc means data=MUW.Telcom maxdec=2 N NMISS MIN MEAN STD MAX;
var MonthlyRevenue;
run;

/*imputation of missing: mean=58.83*/
proc sql;
create table Telco_revenue as
select *, coalesce (MonthlyRevenue,58.83) as MonthlyRevenue_updated
from MUW.Telcom;
run;

/*confirm  missing MONTHLY REVENUE values*/
TITLE "missing month in revenue data";
proc means data=Telco_revenue maxdec=2 N NMISS MIN MEAN STD MAX;
var MonthlyRevenue_updated;
run;

ods pdf file ="C:\Users\Admin\Desktop\SAS PROJECT\monthinservice_graph_1" style= MoonFlower notoc; ;
TITLE "Monthly Revenue Distribution  Analysis ";
proc sgpanel data = Telco_revenue;  
panelby Churn / columns = 2;  
histogram MonthlyRevenue_updated;  
density MonthlyRevenue_updated / type = kernel;  
colaxis label = 'Monthly revenue';  
run;
ods pdf close;

Title 'Analysis of  monthly revenue-Active and Deactivated Accounts';
proc sgplot data=Telco_revenue noborder;
hbar Churn / response=MonthlyRevenue_updated stat=sum group=Churn displaybaseline=auto barwidth=0.6
seglabel datalabel dataskin=pressed;
yaxis display=(noline noticks nolabel);
xaxis display=(noline noticks nolabel) grid;
keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
/*format MonthsInService 8.0;*/
run;

/*scan for missing MONTHLY REVENUE*/
TITLE "missing month in minutes data";
proc means data=MUW.Telcom maxdec=2 N NMISS MIN MEAN STD MAX;
var MonthlyMinutes;
run;

/*imputation of missing: mean=525.65*/
proc sql;
create table Telco_minutes as
select *, coalesce (MonthlyMinutes,525.65) as MonthlyMinutes_updated
from MUW.Telcom;
run;

/*confirm  missing MONTHLY minutes values*/
TITLE "missing month in revenue data";
proc means data=Telco_minutes maxdec=2 N NMISS MIN MEAN STD MAX;
var MonthlyMinutes_updated;
run;


ods pdf file ="C:\Users\Admin\Desktop\SAS PROJECT\monthinservice_graph_1" style= MoonFlower notoc; ;
TITLE "monthly revenue analysis";
proc sgpanel data = Telco_minutes;  
panelby Churn / columns = 2;  
histogram MonthlyMinutes_updated;  
density MonthlyMinutes_updated;  density MonthlyMinutes_updated/ type = kernel;  
colaxis label = 'Monthly revenue';  
run;
ods pdf close;


/*scan for missing MONTHLY RECURRING CHARGES*/
TITLE "missing TotalRecurringCharge values";
proc means data=MUW.Telcom maxdec=2 N NMISS MIN MEAN STD MAX;
var TotalRecurringCharge;
run;

/*imputation of missing: mean=46.83*/
proc sql;
create table Telco_mcharges as
select *, coalesce (TotalRecurringCharge,46.83) as TotalRecurringCharge_updated
from MUW.Telcom;
run;

/*confirm  missing MONTHLY CHARGES values*/
TITLE "missing total recurring charges values";
proc means data=Telco_mcharges maxdec=2 N NMISS MIN MEAN STD MAX;
var TotalRecurringCharge_updated;
run;


TITLE "Total recurring charges analysis-consolidated";
proc sgplot data=MUW.Telcom;
histogram TotalRecurringCharge;
density TotalRecurringCharge;
title"Monthly total revenue distribution";
run;


ods pdf file ="C:\Users\Admin\Desktop\SAS PROJECT\monthinservice_graph_1" style= MoonFlower notoc; ;
TITLE "Total recurring charges analysis";
proc sgpanel data = Telco_mcharges;  
panelby Churn / columns = 2;  
histogram TotalRecurringCharge_updated ;  
density TotalRecurringCharge_updated;density TotalRecurringCharge_updated/ type = kernel; 
colaxis label = 'Total recurring charges';  
run;
ods pdf close;

/*TITLE "Total recurring charges analysis*/

TITLE "Total recurring charges analysis";
proc sgplot data = Telco_mcharges ; 
histogram TotalRecurringCharge_updated / showbins;  
density TotalRecurringCharge_updated;  
density TotalRecurringCharge_updated / type = kernel;  
yaxis grid;  xaxis label = 'total charges';  
keylegend / location = inside     position = topright; 
 title 'Distribution of total charges'; 
run;


/*scan for missing dropped calls*/
TITLE "missing TotalRecurringCharge values";
proc means data=MUW.Telcom maxdec=2 N NMISS MIN MEAN STD MAX;
var DroppedCalls
;
run;

/* no missing for dropped calls*/

/*distribution of monthly revenue*/

proc sgplot data=MUW.Telcom;
histogram TotalRecurringCharge;
density TotalRecurringCharge;
title"Monthly total revenue distribution";
run;


/*scan for missing under equipment days*/
TITLE "missing equipment days values";
proc means data=MUW.Telcom maxdec=2 N NMISS MIN MEAN STD MAX;
var CurrentEquipmentDays;
run;


data MUW.Equip_days;
set MUW.Telcom_data;
if CurrentEquipmentDays eq . then delete;
run;

/*confirm deletion*/
proc means data=MUW.Equip_days maxdec=2 N NMISS MIN MEAN STD MAX;
var CurrentEquipmentDays;
run;

ods pdf file ="C:\Users\Admin\Desktop\SAS PROJECT\monthinservice_graph_1" style= MoonFlower notoc; ;
TITLE "Equipment days analysis";
proc sgpanel data = Telco_mcharges;  
panelby Churn / columns = 2;  
histogram CurrentEquipmentDays ;  
density CurrentEquipmentDays;density CurrentEquipmentDays/ type = kernel; 
colaxis label = 'Total recurring charges';  
run;
ods pdf close;

/*Analysis month in equipments days */

proc format;
value equip_days low-365 ="from 0 days to 1yr"
				365-730	="Between one to 2yrs"
				730-1095	="Between 2 to 3yrs"
				1095-1460 	="Between 3 to 4yrs"
				1460-1825	="Between 4 to 5yrs"
				1825-high	="Above 5yrs";
				run;

proc sgplot data=MUW.Equip_days noborder;
vbar CurrentEquipmentDays /datalabel;
keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
format CurrentEquipmentDays equip_days.;
title "Grouped equipment days  Analysis";
run;

proc freq data=MUW.Telcom order=data;
   tables Churn*CurrentEquipmentDays / expected cellchi2 norow nocol chisq;
   output out=ChiSqData n nmiss pchi lrchi;
   format CurrentEquipmentDays equip_days.;
   title 'Chi-Square Tests for equipment days';
run;


Title 'Analysis of equipment days';
proc sgplot data=MUW.Telcom noborder;
hbar CurrentEquipmentDays / response=CurrentEquipmentDays stat=freq group=CurrentEquipmentDays displaybaseline=auto barwidth=0.6
seglabel datalabel dataskin=pressed;
yaxis display=(noline noticks nolabel);
xaxis display=(noline noticks nolabel) grid;
/*keylegend / location=outside position=top fillheight=10 fillaspect=2 ;*/
format CurrentEquipmentDays equip_days.;
run;



/*BIVARIATE & CHI-SQUARE ANALYSIS*/


/*INCOME BANDWITH ANALYSIS*/

data MUW.Telcom_Income; /*formating dates-use this method*/
length Inc_bandwidth $15;
set Telco_mcharges;
	if 0.1< TotalRecurringCharge <25 then Inc_bandwidth ='$0-$24';
	else if	 24<TotalRecurringCharge<50 then Inc_bandwidth ='$25-$49';
	else if	49< TotalRecurringCharge<75 then Inc_bandwidth ='$50-$74';
	else if 74<TotalRecurringCharge<100 then Inc_bandwidth ='$75-$99';
	else if TotalRecurringCharge >99 then Inc_bandwidth='premium';
	run;

proc sgplot data=MUW.Telcom_Income noborder;
vbar Inc_bandwidth /datalabel;
keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
title "BarGraph- Recurring Charges by bandwidth Analysis";
run;

proc freq data=MUW.Telcom_Income order=data;
   tables Churn*Inc_bandwidth / expected cellchi2 norow nocol chisq;
   output out=ChiSqData n nmiss pchi lrchi;
   /*weight Count;*/
   title 'Chi-Square Tests for Inc_bandwidth';
run;

/*Analysis month in service groups*/

proc format;
value months_grp low-12 ="New Activations"
				12-24	="Between one to 2yrs"
				24-36	="Between 2 to 3yrs"
				36-48 	="Between 3 to 4yrs"
				48-60	="Between 4 to 5yrs"
				60-high	="Above 5yrs";
				run;

proc sgplot data=MUW.Telcom noborder;
vbar MonthsInService /datalabel;
keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
format MonthsInService months_grp.;
title "Grouped Month in service  Analysis";
run;

proc freq data=MUW.Telcom_Income order=data;
   tables Churn*MonthsInService / expected cellchi2 norow nocol chisq;
   output out=ChiSqData n nmiss pchi lrchi;
   format MonthsInService months_grp.;
   title 'Chi-Square Tests for month in service grps';
run;


Title 'Analysis of Average month in service days-Active and Deactivated Accounts';

proc sgplot data=MUW.Telcom_data noborder;
hbar Churn / response=MonthsInService stat=mean group=Churn displaybaseline=auto barwidth=0.6
seglabel datalabel dataskin=pressed;
yaxis display=(noline noticks nolabel);
xaxis display=(noline noticks nolabel) grid;
keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
/*format MonthsInService 8.0;*/
run;

ods graphics on;
proc anova data = MUW.Telcom;
   class Churn;
   model  MonthlyRevenue= Churn;
   means Churn/scheffe;
   title "customer monthly revenue analysis";
run;
ods graphics off;



Title 'Analysis of  dropped calls-Active and Deactivated Accounts';

proc sgplot data=MUW.Telcom noborder;
hbar Churn / response=DroppedCalls stat=sum group=Churn displaybaseline=auto barwidth=0.6
seglabel datalabel dataskin=pressed;
yaxis display=(noline noticks nolabel);
xaxis display=(noline noticks nolabel) grid;
keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
/*format MonthsInService 8.0;*/
run;

ods graphics on;
proc anova data = MUW.Telcom;
   class Churn;
   model  DroppedCalls= Churn;
   means Churn/scheffe;
   title "customer monthly revenue analysis";
run;
ods graphics off;

proc sgplot data=MUW.Telcom;
   hbar MaritalStatus / colormodel=twocolorramp;
   keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
run;


Title 'Analysis of churn by demographics-Marital Status';
proc sgplot data=MUW.Telcom_Income;
vbar MaritalStatus / datalabel response=TotalRecurringCharge Group=Inc_bandwidth;
run;


proc freq data=MUW.Telcom order=data;
   tables Churn*MaritalStatus / expected cellchi2 norow nocol chisq;
   output out=ChiSqData n nmiss pchi lrchi;
   /*weight Count;*/
   title 'Chi-Square Tests for Marital status';
run;


/*analysis of occupation vs churn*/

Title 'Analysis of churn by demographics-Occupation';
proc sgplot data=MUW.Telcom_Income noborder;
vbar Occupation /datalabel response=TotalRecurringCharge Group=Inc_bandwidth;;
keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
/*format MonthsInService 8.0;*/
run;

proc freq data=MUW.Telcom order=data;
   tables Churn*Occupation / expected cellchi2 norow nocol chisq;
   output out=ChiSqData n nmiss pchi lrchi;
   /*weight Count;*/
   title 'Chi-Square Tests for Occupation';
run;


/*analysis of CreditRating vs churn*/

Title 'Analysis of churn by Credit Rating';
proc sgplot data=MUW.Telcom_Income noborder;
vbar CreditRating /datalabel response=TotalRecurringCharge Group=Inc_bandwidth;;;
keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
/*format MonthsInService 8.0;*/
run;


proc freq data=MUW.Telcom order=data;
   tables Churn*CreditRating / expected cellchi2 norow nocol chisq;
   output out=ChiSqData n nmiss pchi lrchi;
   /*weight Count;*/
   title 'Chi-Square Tests for Credit Rating';
run;

/*primcode area Analysis*/
title "Analysis of churn by PriznCode";
proc freq data=MUW.Telcom order=data;
   tables Churn*PrizmCode
 / expected cellchi2 norow nocol chisq;
   output out=ChiSqData n nmiss pchi lrchi;
   /*weight Count;*/
   
run;

title "Analysis of Revenue by PriznCode-Churn";
proc sgplot data=MUW.Telcom noborder;
hbar PrizmCode / response=TotalRecurringCharge stat=sum group=Churn displaybaseline=auto barwidth=0.6
seglabel datalabel dataskin=pressed;
yaxis display=(noline noticks nolabel);
xaxis display=(noline noticks nolabel) grid;
keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
format MonthsInService 8.0;
run;

/*New/Not cellphone users  Analysis*/
title "Analysis of Not New cellphone users";
proc freq data=MUW.Telcom order=data;
   tables Churn*NotNewCellphoneUser / expected cellchi2 norow nocol chisq;
   output out=ChiSqData n nmiss pchi lrchi;
   /*weight Count;*/
   run;

title "Analysis of New cellphone users";
proc freq data=MUW.Telcom order=data;
   tables Churn*NewCellphoneUser / expected cellchi2 norow nocol chisq;
   output out=ChiSqData n nmiss pchi lrchi;
   /*weight Count;*/
   run;


title "Analysis of Revenue by cellphone users";
proc sgplot data=MUW.Telcom noborder;
hbar NewCellphoneUser / response=TotalRecurringCharge stat=sum group=Churn displaybaseline=auto barwidth=0.6
seglabel datalabel dataskin=pressed;
yaxis display=(noline noticks nolabel);
xaxis display=(noline noticks nolabel) grid;
keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
format MonthsInService 8.0;
run;



/*Revenue Analysis by Credit Rating, grouped by Churn*/

title "Analysis of Revenue by Credit Rating-Churn";
proc sgplot data=MUW.Telcom noborder;
hbar CreditRating / response=TotalRecurringCharge stat=sum group=Churn displaybaseline=auto barwidth=0.6
seglabel datalabel dataskin=pressed;
yaxis display=(noline noticks nolabel);
xaxis display=(noline noticks nolabel) grid;
keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
format MonthsInService 8.0;
run;


/*Revenue Analysis by IncomeGroup, grouped by Churn status*/

title "Analysis of Revenue by IncomeGroup-Churn";
proc sgplot data=MUW.Telcom noborder;
hbar IncomeGroup / response=TotalRecurringCharge stat=sum group=Churn displaybaseline=auto barwidth=0.6
seglabel datalabel dataskin=pressed;
yaxis display=(noline noticks nolabel);
xaxis display=(noline noticks nolabel) grid;
keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
format MonthsInService 8.0;
run;


/*Revenue Analysis by IncomeGroup, grouped by Churn status*/

title "Analysis of Revenue by marital status-Churn";
proc sgplot data=MUW.Telcom noborder;
hbar MaritalStatus / response=TotalRecurringCharge stat=sum group=Churn displaybaseline=auto barwidth=0.6
seglabel datalabel dataskin=pressed;
yaxis display=(noline noticks nolabel);
xaxis display=(noline noticks nolabel) grid;
keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
format MonthsInService 8.0;
run;

title "Analysis of blocked calls by Churn";
proc sgplot data=MUW.Telcom noborder;
hbar Churn / response= BlockedCalls stat=sum group=Churn displaybaseline=auto barwidth=0.6
seglabel datalabel dataskin=pressed;
yaxis display=(noline noticks nolabel);
xaxis display=(noline noticks nolabel) grid;
keylegend / location=outside position=top fillheight=10 fillaspect=2 ;
format MonthsInService 8.0;
run;

ods graphics on;
proc anova data = MUW.Telcom;
   class Churn;
   model  BlockedCalls= Churn;
   means Churn/scheffe;
   title "customer BlockedCalls analysis";
run;
ods graphics off;


/*OUTLIER DETECTION*/

	*monthly revenue;
	*total recurring charges
	*monthly minutes;
	*dropped calls;
	*blocked calls;


/*calculate quartiles and inter quartiles for Monthly revenue*/


proc sgplot data= Telco_revenue;
vbox  MonthlyRevenue_updated;
run;


proc means data=Telco_revenue maxdec=2;
var MonthlyRevenue_updated;
output out =revenue p25=Q1 p75=Q3 qrange =IQR;
run;

data revenue_01;
set revenue;
lower_limit =Q1-(3*IQR);
upper_limit=Q3+(3*IQR);
drop _TYPE_ _FREQ_;
run;
proc print data=revenue_01; run;

/*create catesian product*/

proc sql;
create table revenue_02 as
select A.*,B.*
from Telco_revenue as A, revenue_01 as B
;
quit;


data revenue_03;
set revenue_02;
if MonthlyRevenue_updated le lower_limit then range ="below lower limit";
else if  MonthlyRevenue_updated ge upper_limit then range ="above upper limit";
else range ="within range"
;
run;

/*bivariate analysis for monthly revenue range*/

proc freq data=revenue_03 order=data;
   tables Churn*range / expected cellchi2 norow nocol chisq;
   output out=ChiSqData n nmiss pchi lrchi;
   /*weight Count;*/
   title 'Chi-Square Tests for monthly revenue range';
run;



/*calculate quartiles and inter quartiles for monthly recurring charges */

proc means data=Telco_mcharges maxdec=2;
var TotalRecurringCharge_updated;
output out =charges p25=Q1 p75=Q3 qrange =IQR;
run;

data charges_01;
set charges;
lower_limit =Q1-(3*IQR);
upper_limit=Q3+(3*IQR);
drop _TYPE_ _FREQ_;
run;
proc print data=charges_01; run;

/*create catesian product*/

proc sql;
create table charges_02 as
select A.*,B.*
from Telco_mcharges as A, charges_01 as B
;
quit;


data charges_03;
set charges_02;
if TotalRecurringCharge_updated le lower_limit then charge_range ="below lower limit";
else if  TotalRecurringCharge_updated ge upper_limit then charge_range ="above upper limit";
else charge_range ="within range"
;
run;


proc freq data=charges_03 order=data;
   tables Churn*charge_range / expected cellchi2 norow nocol chisq;
   output out=ChiSqData n nmiss pchi lrchi;
   /*weight Count;*/
   title 'Chi-Square Tests for monthly charge range';
run;



/*calculate quartiles and inter quartiles for monthly recurring charges */

proc means data=Telco_mcharges maxdec=2;
var TotalRecurringCharge_updated;
output out =charges p25=Q1 p75=Q3 qrange =IQR;
run;

data charges_01;
set charges;
lower_limit =Q1-(3*IQR);
upper_limit=Q3+(3*IQR);
drop _TYPE_ _FREQ_;
run;
proc print data=charges_01; run;

/*create catesian product*/

proc sql;
create table charges_02 as
select A.*,B.*
from Telco_mcharges as A, charges_01 as B
;
quit;


data charges_03;
set charges_02;
if TotalRecurringCharge_updated le lower_limit then charge_range ="below lower limit";
else if  TotalRecurringCharge_updated ge upper_limit then charge_range ="above upper limit";
else charge_range ="within range"
;
run;


proc freq data=charges_03 order=data;
   tables Churn*charge_range / expected cellchi2 norow nocol chisq;
   output out=ChiSqData n nmiss pchi lrchi;
   /*weight Count;*/
   title 'Chi-Square Tests for monthly charge range';
run;



/*calculate range for monthly minutes */

proc univariate data=Telco_minutes ;
var MonthlyMinutes_updated;
run;


proc means data=Telco_minutes maxdec=2;
var MonthlyMinutes_updated;
output out =call_minutes p25=Q1 p75=Q3 qrange =IQR;
run;

data minutes_01;
set call_minutes;
lower_limit =Q1-(3*IQR);
upper_limit=Q3+(3*IQR);
drop _TYPE_ _FREQ_;
run;
proc print data=minutes_01; run;

/*create catesian product*/

proc sql;
create table minutes_02 as
select A.*,B.*
from Telco_minutes as A, minutes_01 as B
;
quit;


data minutes_03;
set minutes_02;
if MonthlyMinutes_updated le lower_limit then call_range ="below lower limit";
else if  MonthlyMinutes_updated ge upper_limit then call_range ="above upper limit";
else call_range ="within range"
;
run;


proc freq data=minutes_03 order=data;
   tables Churn*call_range / expected cellchi2 norow nocol chisq;
   output out=ChiSqData n nmiss pchi lrchi;
   /*weight Count;*/
   title 'Chi-Square Tests for call range in minutes';
run;


*Scatterplot Matrix; 
ods pdf file ="C:\Users\Admin\Desktop\SAS PROJECT\matrix_graph_1" style= MoonFlower notoc;
proc sgscatter data = MUW.Telcom;  
matrix MonthlyRevenue TotalRecurringCharge MonthsInService CurrentEquipmentDays; 
/*label MonthsInService = 'transformed';*/ 
title 'Scatterplot Matrix of churn  Risk Factors'; 
run;
ods pdf close































/*************end of code*******************/
