/*
PROC IMPORT OUT= WORK.imputation
            DATAFILE= "C:\Users\Hmcmanus\Desktop\WORK_UNITS\ASR\ASR2015\CASCADES\notifications2015_2.xls" 
            DBMS=excel replace;
     SHEET="Sheet1"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
*/


data WORK.imputation    ;
%let _EFIERR_ = 0; /* set the ERROR detection macro variable */
infile
'C:\Users\Rgray\Desktop\BackProjectionFiles\notifications2015-3-exposureDOBreplaced.csv' delimiter
= ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
informat thivno best32. ;
informat state best32. ;
informat stateno best32. ;
informat postcode best32. ;
informat sex best32. ;
informat dob ddmmyy10. ;
informat dob2 ddmmyy10. ;
informat cob best32. ;
informat datehiv ddmmyy10. ;
informat cd4count best32. ;
informat expcode $2. ;
informat dateneg ddmmyy10. ;
informat dateill $1. ;
informat dateindet $1. ;
informat datelastct ddmmyy10. ;
informat datedeath ddmmyy10. ;
informat datecreated ddmmyy10. ;
informat previ_diag_overseas $1. ;
informat country_prev_diag $1. ;
informat datediagos ddmmyy10. ;
informat recent best32. ;
informat datehivdec best32. ;
informat yearbirthdec best32. ;
informat exp best32. ;
format thivno best12. ;
format state best12. ;
format stateno best12. ;
format postcode best12. ;
format sex best12. ;
format dob ddmmyy10. ;
format dob2 ddmmyy10. ;
format cob best12. ;
format datehiv ddmmyy10. ;
format cd4count $1. ;
format expcode $2. ;
format dateneg ddmmyy10. ;
format dateill $1. ;
format dateindet $1. ;
format datelastct ddmmyy10. ;
format datedeath ddmmyy10. ;
format datecreated ddmmyy10. ;
format previ_diag_overseas $1. ;
format country_prev_diag $1. ;
format datediagos ddmmyy10. ;
format recent best12. ;
format datehivdec best12. ;
format yearbirthdec best12. ;
format exp best12. ;
input
thivno
state
stateno
postcode
sex
dob
dob2
cob
datehiv
cd4count $
expcode $
dateneg 
dateill $
dateindet $
datelastct
datedeath
datecreated
previ_diag_overseas $
country_prev_diag $
datediagos 
recent
datehivdec
yearbirthdec
exp
;
if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
run;

data imputation_sqr;
set imputation;
cd4_sqrt=sqrt(cd4count );
age=datehivdec-yearbirthdec; 
run;



proc glm data = imputation_sqr;
class state sex exp;
model cd4_sqrt=age sex datehivdec  exp/intercept solution;
output out=A h=hii residual=raw student=standard rstudent=student predicted=fit;
run;


/*Conduct MCMC multiple imputation*/
proc mi data=imputation_sqr seed=42037921
nimpute=5 out=miout2;
mcmc;
var sex datehivdec exp age cd4_sqrt ;
run;

data miout2;
set miout2;
/* change the CD4 sqrt to a CD4 count*/
cd4base= cd4_sqrt**2;	
yearbirth=floor(datehivdec-age);
run;

DATA subset;
  SET work.miout2;
IF _Imputation_ = 1;

PROC EXPORT DATA= WORK.subset OUTFILE= "C:\Users\Rgray\Desktop\BackProjectionFiles\notifications2015imputation.xls" DBMS=XLS REPLACE;
SHEET="Dataset_1";
RUN;




