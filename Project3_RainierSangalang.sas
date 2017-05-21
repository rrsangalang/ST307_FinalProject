/***************************************
AUTHOR: Rainier Sangalang
GROUP MEMBERS: Vy Tran 100%
			   Liesl Miranda 100%
GROUP NUMBER: 15
CLASS: ST307 (005)
ASSIGNMENT: Project 3
DATE: 5/3/2017
****************************************/

libname Project3 "C:\Users\rsangal\Downloads";

data Project3.Lakes;
	infile "C:\Users\rsangal\Downloads\fish.txt" dsd dlm = '09'x firstobs=2;
	input name: $19. hg n elev sa depth ltype $ stype$ da rf fr dam latdeg latmin latsec londeg lonmin lonsec;
	latdec = latdeg + latmin/60 + latsec/3600; *translating latitude to decimal;
	londec = londeg + lonmin/60 + lonmin/3600; *translating longitude to decimal;
	format elev sa comma6. latdec londec 6.3; *formatting variables;
	label name = "Name of Lake" hg = "Mercury Content of Sample (ppm)" n = "Number of Fish in Sample" elev = "Elevation of lake (ft)"
		  sa = "Surface Area (acres)" depth = "Max Depth (ft)" ltype = "Lake Type" stype = "Stratification Type"
		  da = "Drainage Area" rf = "Runoff Factor" fr = "Flushing Rate" dam = "Dam" latdec = "Latitude (deg)" londec = "Longitude (deg)";
	drop latdeg latmin latsec londeg lonmin lonsec; *dropping all latitude and logitude that are not in decimals;
run;

proc glm DATA = Project3.Lakes PLOTS = ALL;
	CLASS ltype;
	MODEL hg = ltype; *hg is response, ltype is predictor;
	LSMEANS ltype/ADJUST = Tukey ALPHA =.10 CL; *requests for 90% confidence interval;
run;
quit;

data Project3.Lakes; 
	set Project3.Lakes;
	loghg = log(hg); *adds new variable to lakes data set;
	label loghg = "Log of Mercury"; *labels new variable;
run;

proc glm DATA = Project3.Lakes PLOTS = ALL;
	CLASS ltype;
	MODEL loghg = ltype; *loghg is response, ltype is predictor;
	LSMEANS ltype/ADJUST = Tukey ;
run;
quit;

proc corr DATA = Project3.Lakes PLOTS=matrix ;
	var hg elev sa da fr; * calculates correlation for these variables;
run;

proc glm DATA = Project3.Lakes PLOTS = ALL;
	model hg = fr / CLPARM ALPHA = .01; *produce a 99% confidence interval for the slope parameter;
run;
quit;

data temp; *creates temporary data set for missing y method;
	input name: $19. hg n elev sa depth ltype $ stype$ da rf fr dam latdec londec loghg;
	DATALINES;
	. . . . . . . . . . .78 . . . . 
; *inputs only information for flushing rate;
RUN;

proc datasets;
	append base = Project3.Lakes DATA = Temp; *appends temp data set to lakes data set;
run;

proc GLM Data = Project3.Lakes PLOTS = ALL;
	model hg = fr / CLM Alpha = .01; *produce a 99% confidence interval for individual values 
									 (including new fr = .78 );
run;
quit;






