function [CD4CountHistogram, Data]=GenerateCD4Count(TestingParameters, Pxi)
% This function takes a healthy population and simulates the CD4 decline
% according to assumptions contained in in Pxi and the TestingP. In doing
% so, it creates the number of people expected in the correct proportions
% by CD4. 


StepSize=0.1;

%Start with the correct number of observations
SimulatedPopSize=Pxi.SimulatedPopSize;

IndexTest=false(1, SimulatedPopSize);
NumIndex=1:SimulatedPopSize;
Data.Time=zeros(1, SimulatedPopSize);
Data.CD4=zeros(1, SimulatedPopSize);

% Generate an intital distribution
LogInitialCD4Vector = normrnd(Pxi.MedianLogHealthyCD4, Pxi.StdLogHealthyCD4, [1 SimulatedPopSize]);
InitialCD4Vector=exp(LogInitialCD4Vector);
Data.InitialCD4=InitialCD4Vector;

% clf;
% hist(Data.InitialCD4, 50:100:1450);
% pause

% Kaufmann 1999 
% Kaufmann GR, Cunningham P, Zaunders J, Law M, Vizzard J, Carr A, et al. Impact of Early HIV-1 RNA and T-Lymphocyte Dynamics During Primary HIV-1 Infection on the Subsequent Course of HIV-1 RNA Levels and CD4+ T-Lymphocyte Counts in the First Year of HIV-1 Infection. JAIDS Journal of Acquired Immune Deficiency Syndromes 1999,22:437-444.
% nadir 17 days after symptoms of 418, followed by 756 at day 40.        

% For all people, find the probability of being diagnosed in the firt 17 days 
UntestedIndex=NumIndex(IndexTest==false);%in this case, all
MeanCD4Count=InitialCD4Vector(UntestedIndex)*(1+Pxi.FractionalDeclineToTrough)/2;
Duration=Pxi.TimeUntilTrough;
DiagnosedThisStepSubIndex=DiagnosedDuringStep(TestingParameters, MeanCD4Count, Duration);
DiagnosedThisStepIndexInTheMainArray=UntestedIndex(DiagnosedThisStepSubIndex);
NumberDiagnosedThisStep=sum(DiagnosedThisStepSubIndex);
%Calculate the time
RandomDistanceAlongThisStep=rand(1, NumberDiagnosedThisStep);
TimeAtDiagnosis=Pxi.TimeUntilTrough*RandomDistanceAlongThisStep;
Data.Time(DiagnosedThisStepSubIndex)=TimeAtDiagnosis;
Data.CD4(DiagnosedThisStepSubIndex)=InitialCD4Vector(DiagnosedThisStepSubIndex).*((1-RandomDistanceAlongThisStep)*1+RandomDistanceAlongThisStep*Pxi.FractionalDeclineToTrough);
% Set those as having been diagnosed
IndexTest(DiagnosedThisStepSubIndex)=true;


% In the next step, only look at those who are undiagnosed
UntestedIndex=NumIndex(IndexTest==false);
MeanCD4Count=InitialCD4Vector(UntestedIndex)*(Pxi.FractionalDeclineToRebound+Pxi.FractionalDeclineToTrough)/2;
Duration=Pxi.TimeUntilRebound-Pxi.TimeUntilTrough;
DiagnosedThisStepSubIndex=DiagnosedDuringStep(TestingParameters, MeanCD4Count, Duration);
DiagnosedThisStepIndexInTheMainArray=UntestedIndex(DiagnosedThisStepSubIndex);
NumberDiagnosedThisStep=sum(DiagnosedThisStepSubIndex);
%Calculate the time
RandomDistanceAlongThisStep=rand(1, NumberDiagnosedThisStep);
TimeAtDiagnosis=Pxi.TimeUntilTrough+(Pxi.TimeUntilRebound-Pxi.TimeUntilTrough)*RandomDistanceAlongThisStep;

Data.Time(DiagnosedThisStepIndexInTheMainArray)=TimeAtDiagnosis;
Data.CD4(DiagnosedThisStepIndexInTheMainArray)=InitialCD4Vector(DiagnosedThisStepIndexInTheMainArray).*((1-RandomDistanceAlongThisStep)*1+RandomDistanceAlongThisStep*Pxi.FractionalDeclineToTrough);
IndexTest(DiagnosedThisStepIndexInTheMainArray)=true;


%Calculate the starting point of all the people (yes this is inefficient, but much cleaner for code)
CD4AtRebound=InitialCD4Vector.*Pxi.FractionalDeclineToRebound;
SqrCD4AtRebound=sqrt(CD4AtRebound);

% Generate a squareroot decline for these individuals
m=Pxi.SquareRootAnnualDecline;
v=(Pxi.SDSQRDeclineIndividual)^2;
mu = log((m^2)/sqrt(v+m^2));
sigma = sqrt(log(v/(m^2)+1));
SQRDecline = lognrnd(mu,sigma,1,SimulatedPopSize);
%Remove declines that are less than 10% of the squareroot annual decline
%This is to avoid negative declines and divide by zero errors. Note that it is expected that around 0.9% of the population would have this level according to these calculations
SQRDecline(SQRDecline<0.1*Pxi.SquareRootAnnualDecline)=[];
[~, NumberRemaining]=size(SQRDecline);
if NumberRemaining<1
    error('The SQRDecline function resulted in too few samples to resample from. This may be due to a decline rate that is too shallow');
end
%Resample to produce the required number of samples
ResampledSQRDecline = randsample(SQRDecline,SimulatedPopSize-NumberRemaining,'true'); % with replacement
SQRDecline=[SQRDecline ResampledSQRDecline];

TimeSinceRebound=0;
Step=0;
while (sum(IndexTest)<SimulatedPopSize)
    Step=Step+1;
%     disp( 'Step');
%     disp(Step);
%     disp(sum(IndexTest));%
%     disp(TimeSinceRebound);% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeMidpoint=TimeSinceRebound+StepSize/2;
    
    UntestedIndex=NumIndex(IndexTest==false);
    UntestedDeclines=SQRDecline(UntestedIndex);
    UntestedSqrCD4AtRebound=SqrCD4AtRebound(UntestedIndex);
    
    % Calculate CD4 at midpoint to find the average testing rate
    % We don't need to worr about stochasticity at this point because the
    % average CD4 is more likely to indicate health at a point in time than
    % day to day variation.
    
    SqrCD4AtMidpoint=UntestedSqrCD4AtRebound-TimeMidpoint*UntestedDeclines;
    %Make all <0 CD4s zero
    SqrCD4AtMidpoint(SqrCD4AtMidpoint<0)=0;
    CD4AtMidpoint= SqrCD4AtMidpoint.^2;
    
    DiagnosedThisStepSubIndex=DiagnosedDuringStep(TestingParameters, CD4AtMidpoint, StepSize);

    DiagnosedThisStepIndexInTheMainArray=UntestedIndex(DiagnosedThisStepSubIndex);
    NumberDiagnosedThisStep=sum(DiagnosedThisStepSubIndex);
    %Calculate the time
    RandomDistanceAlongThisStep=rand(1, NumberDiagnosedThisStep);
    TimeSinceReboundAtDiagnosis=TimeSinceRebound+RandomDistanceAlongThisStep*StepSize;
    
    Data.Time(DiagnosedThisStepIndexInTheMainArray)=Pxi.TimeUntilRebound+TimeSinceReboundAtDiagnosis;
    
    Data.CD4(DiagnosedThisStepIndexInTheMainArray)=CD4AtMidpoint(DiagnosedThisStepSubIndex);
    IndexTest(DiagnosedThisStepIndexInTheMainArray)=true;


    TimeSinceRebound=TimeSinceRebound+StepSize;

    %Finally, to catch problems with testing rates, if it has been more than 50 years, stop
    if TimeSinceRebound>50
        warning('Some of the elements in the GenerateCD4Count reached 50 years, which is probably too long');
    end
end






%% Add stochasticity to all TestingCD4
% Hughes, M.D. et al "Within-Subject Variation in CD4..." 1994 JID
% On the loge scale, the relationship between the within-subject SO and the underlying CD4 cell count of mu was given by (sigma = 0.930 - 0.110 loge(mu).

mu=Data.CD4;
logmu=log(mu+10);%plus 10 to avoid the problems associated with log zero. Note that for people with a CD4 of zero, this should be within range when selecting "nearest neighbours"
sigma = 0.930 - 0.110*logmu;
LogSamples=normrnd(logmu,sigma);
Data.CD4=exp(LogSamples);

%% Return results
CD4CountHistogram=hist(Data.CD4, 50:100:1450);

end