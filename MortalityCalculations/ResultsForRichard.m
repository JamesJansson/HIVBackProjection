% These are sumplementary scripts that are used to extract information about MSM incidence, deaths etc 
% to get this to work, 
% 1) run Backprojection in the main folder
% 2) move to the MoratlityCalculations folder
% 3) run CalculateAIDSAndMortality
% 4) Run this script

clear MSMResultsRG;

MSMResultsRG.Local.Undiagnosed.Time=MSMTotalUndiagnosedByTime.Time;
MSMResultsRG.Local.Undiagnosed.UCI=prctile(MSMTotalUndiagnosedByTime.N, 97.5, 1);
MSMResultsRG.Local.Undiagnosed.LCI=prctile(MSMTotalUndiagnosedByTime.N, 2.5, 1);
MSMResultsRG.Local.Undiagnosed.Median=median(MSMTotalUndiagnosedByTime.N, 1);
MSMResultsRG.Local.Undiagnosed.Mean=mean(MSMTotalUndiagnosedByTime.N, 1);
MSMResultsRG.Local.Undiagnosed.N=MSMTotalUndiagnosedByTime.N;



MSMResultsRG.Local.Diagnoses=MSMDiagnosesByYear;

MSMResultsRG.Local.Incidence.UCI=prctile(MSMDistributionDiagnosedInfections, 97.5, 1);
MSMResultsRG.Local.Incidence.LCI=prctile(MSMDistributionDiagnosedInfections, 2.5, 1);
MSMResultsRG.Local.Incidence.Median=median(MSMDistributionDiagnosedInfections, 1);
MSMResultsRG.Local.Incidence.Mean=mean(MSMDistributionDiagnosedInfections, 1);
MSMResultsRG.Local.Incidence.N=MSMDistributionDiagnosedInfections;



% MSM deaths
RGTime=1980:2014;
[~, RGTimeSlotCount]=size(RGTime);
MSMResultsRG.Local.Deaths.N=zeros(200, RGTimeSlotCount);
MSMResultsRG.All.Deaths.N=zeros(200, RGTimeSlotCount);

MSMResultsRG.Local.Deaths.Time=RGTime;
MSMResultsRG.All.Deaths.Time=RGTime;



PCount=0;
for P = MSMMort
    PCount=PCount+1;
    disp(PCount);
    for SimCount=1:200
        Ref=RGTime==floor(P.YearOfDeath(SimCount));
        if (P.PreviouslyDiagnosedOverseas==0)% local infection
            MSMResultsRG.Local.Deaths.N(SimCount, Ref)=MSMResultsRG.Local.Deaths.N(SimCount, Ref)+1;
        end
        % Run this for all individuals
        MSMResultsRG.All.Deaths.N(SimCount, Ref)=MSMResultsRG.All.Deaths.N(SimCount, Ref)+1;
        
       
    end
end

MSMResultsRG.Local.Deaths.UCI=prctile(MSMResultsRG.Local.Deaths.N, 97.5, 1);
MSMResultsRG.Local.Deaths.LCI=prctile(MSMResultsRG.Local.Deaths.N, 2.5, 1);
MSMResultsRG.Local.Deaths.Median=median(MSMResultsRG.Local.Deaths.N, 1);
MSMResultsRG.Local.Deaths.Mean=mean(MSMResultsRG.Local.Deaths.N, 1);

MSMResultsRG.All.Deaths.UCI=prctile(MSMResultsRG.All.Deaths.N, 97.5, 1);
MSMResultsRG.All.Deaths.LCI=prctile(MSMResultsRG.All.Deaths.N, 2.5, 1);
MSMResultsRG.All.Deaths.Median=median(MSMResultsRG.All.Deaths.N, 1);
MSMResultsRG.All.Deaths.Mean=mean(MSMResultsRG.All.Deaths.N, 1);



MSMResultsRG.Local.CurrentlyDiagnosed.N=zeros(200, RGTimeSlotCount);
MSMResultsRG.All.CurrentlyDiagnosed.N=zeros(200, RGTimeSlotCount);

MSMResultsRG.Local.CurrentlyDiagnosed.Time=RGTime;
MSMResultsRG.All.CurrentlyDiagnosed.Time=RGTime;

YearCount=0;
for Year = RGTime
    YearCount=YearCount+1;
    disp(YearCount);
    PCount=0;
    for P = MSMMort
        PCount=PCount+1;
        
        CurrentlyAliveByYearResult=P.AliveAndHIVPosInYear(Year);
        if (P.PreviouslyDiagnosedOverseas==0)% local infection
            MSMResultsRG.Local.CurrentlyDiagnosed.N(:, YearCount)=MSMResultsRG.Local.CurrentlyDiagnosed.N(:, YearCount)+CurrentlyAliveByYearResult';
        end
        % Run this for all individuals
        MSMResultsRG.All.CurrentlyDiagnosed.N(:, YearCount)=MSMResultsRG.All.CurrentlyDiagnosed.N(:, YearCount)+CurrentlyAliveByYearResult';

    end

end


MSMResultsRG.Local.CurrentlyDiagnosed.UCI=prctile(MSMResultsRG.Local.CurrentlyDiagnosed.N, 97.5, 1);
MSMResultsRG.Local.CurrentlyDiagnosed.LCI=prctile(MSMResultsRG.Local.CurrentlyDiagnosed.N, 2.5, 1);
MSMResultsRG.Local.CurrentlyDiagnosed.Median=median(MSMResultsRG.Local.CurrentlyDiagnosed.N, 1);
MSMResultsRG.Local.CurrentlyDiagnosed.Mean=mean(MSMResultsRG.Local.CurrentlyDiagnosed.N, 1);

MSMResultsRG.All.CurrentlyDiagnosed.UCI=prctile(MSMResultsRG.All.CurrentlyDiagnosed.N, 97.5, 1);
MSMResultsRG.All.CurrentlyDiagnosed.LCI=prctile(MSMResultsRG.All.CurrentlyDiagnosed.N, 2.5, 1);
MSMResultsRG.All.CurrentlyDiagnosed.Median=median(MSMResultsRG.All.CurrentlyDiagnosed.N, 1);
MSMResultsRG.All.CurrentlyDiagnosed.Mean=mean(MSMResultsRG.All.CurrentlyDiagnosed.N, 1);




clear NonMSMResultsRG;

NonMSMResultsRG.Local.Undiagnosed.Time=NonMSMTotalUndiagnosedByTime.Time;
NonMSMResultsRG.Local.Undiagnosed.UCI=prctile(NonMSMTotalUndiagnosedByTime.N, 97.5, 1);
NonMSMResultsRG.Local.Undiagnosed.LCI=prctile(NonMSMTotalUndiagnosedByTime.N, 2.5, 1);
NonMSMResultsRG.Local.Undiagnosed.Median=median(NonMSMTotalUndiagnosedByTime.N, 1);
NonMSMResultsRG.Local.Undiagnosed.Mean=mean(NonMSMTotalUndiagnosedByTime.N, 1);
NonMSMResultsRG.Local.Undiagnosed.N=NonMSMTotalUndiagnosedByTime.N;



NonMSMResultsRG.Local.Diagnoses=NonMSMDiagnosesByYear;

NonMSMResultsRG.Local.Incidence.UCI=prctile(NonMSMDistributionDiagnosedInfections, 97.5, 1);
NonMSMResultsRG.Local.Incidence.LCI=prctile(NonMSMDistributionDiagnosedInfections, 2.5, 1);
NonMSMResultsRG.Local.Incidence.Median=median(NonMSMDistributionDiagnosedInfections, 1);
NonMSMResultsRG.Local.Incidence.Mean=mean(NonMSMDistributionDiagnosedInfections, 1);
NonMSMResultsRG.Local.Incidence.N=NonMSMDistributionDiagnosedInfections;



% NonMSM deaths
RGTime=1980:2014;
[~, RGTimeSlotCount]=size(RGTime);
NonMSMResultsRG.Local.Deaths.N=zeros(200, RGTimeSlotCount);
NonMSMResultsRG.All.Deaths.N=zeros(200, RGTimeSlotCount);

NonMSMResultsRG.Local.Deaths.Time=RGTime;
NonMSMResultsRG.All.Deaths.Time=RGTime;



PCount=0;
for P = NonMSMMort
    PCount=PCount+1;
    disp(PCount);
    for SimCount=1:200
        Ref=RGTime==floor(P.YearOfDeath(SimCount));
        if (P.PreviouslyDiagnosedOverseas==0)% local infection
            NonMSMResultsRG.Local.Deaths.N(SimCount, Ref)=NonMSMResultsRG.Local.Deaths.N(SimCount, Ref)+1;
        end
        % Run this for all individuals
        NonMSMResultsRG.All.Deaths.N(SimCount, Ref)=NonMSMResultsRG.All.Deaths.N(SimCount, Ref)+1;
        
       
    end
end

NonMSMResultsRG.Local.Deaths.UCI=prctile(NonMSMResultsRG.Local.Deaths.N, 97.5, 1);
NonMSMResultsRG.Local.Deaths.LCI=prctile(NonMSMResultsRG.Local.Deaths.N, 2.5, 1);
NonMSMResultsRG.Local.Deaths.Median=median(NonMSMResultsRG.Local.Deaths.N, 1);
NonMSMResultsRG.Local.Deaths.Mean=mean(NonMSMResultsRG.Local.Deaths.N, 1);

NonMSMResultsRG.All.Deaths.UCI=prctile(NonMSMResultsRG.All.Deaths.N, 97.5, 1);
NonMSMResultsRG.All.Deaths.LCI=prctile(NonMSMResultsRG.All.Deaths.N, 2.5, 1);
NonMSMResultsRG.All.Deaths.Median=median(NonMSMResultsRG.All.Deaths.N, 1);
NonMSMResultsRG.All.Deaths.Mean=mean(NonMSMResultsRG.All.Deaths.N, 1);



NonMSMResultsRG.Local.CurrentlyDiagnosed.N=zeros(200, RGTimeSlotCount);
NonMSMResultsRG.All.CurrentlyDiagnosed.N=zeros(200, RGTimeSlotCount);

NonMSMResultsRG.Local.CurrentlyDiagnosed.Time=RGTime;
NonMSMResultsRG.All.CurrentlyDiagnosed.Time=RGTime;

YearCount=0;
for Year = RGTime
    YearCount=YearCount+1;
    disp(YearCount);
    PCount=0;
    for P = NonMSMMort
        PCount=PCount+1;
        
        CurrentlyAliveByYearResult=P.AliveAndHIVPosInYear(Year);
        if (P.PreviouslyDiagnosedOverseas==0)% local infection
            NonMSMResultsRG.Local.CurrentlyDiagnosed.N(:, YearCount)=NonMSMResultsRG.Local.CurrentlyDiagnosed.N(:, YearCount)+CurrentlyAliveByYearResult';
        end
        % Run this for all individuals
        NonMSMResultsRG.All.CurrentlyDiagnosed.N(:, YearCount)=NonMSMResultsRG.All.CurrentlyDiagnosed.N(:, YearCount)+CurrentlyAliveByYearResult';

    end

end


NonMSMResultsRG.Local.CurrentlyDiagnosed.UCI=prctile(NonMSMResultsRG.Local.CurrentlyDiagnosed.N, 97.5, 1);
NonMSMResultsRG.Local.CurrentlyDiagnosed.LCI=prctile(NonMSMResultsRG.Local.CurrentlyDiagnosed.N, 2.5, 1);
NonMSMResultsRG.Local.CurrentlyDiagnosed.Median=median(NonMSMResultsRG.Local.CurrentlyDiagnosed.N, 1);
NonMSMResultsRG.Local.CurrentlyDiagnosed.Mean=mean(NonMSMResultsRG.Local.CurrentlyDiagnosed.N, 1);

NonMSMResultsRG.All.CurrentlyDiagnosed.UCI=prctile(NonMSMResultsRG.All.CurrentlyDiagnosed.N, 97.5, 1);
NonMSMResultsRG.All.CurrentlyDiagnosed.LCI=prctile(NonMSMResultsRG.All.CurrentlyDiagnosed.N, 2.5, 1);
NonMSMResultsRG.All.CurrentlyDiagnosed.Median=median(NonMSMResultsRG.All.CurrentlyDiagnosed.N, 1);
NonMSMResultsRG.All.CurrentlyDiagnosed.Mean=mean(NonMSMResultsRG.All.CurrentlyDiagnosed.N, 1);







