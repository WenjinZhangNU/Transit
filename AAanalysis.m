% Read as table from .xlsx sheet
T = readtable('8-20-2019_Wenjin_Mg_cyc5.xlsx',...
    'Range','A9:J498','ReadRowNames',false);
info = [T(:,1) T(:,7)]; % all useful info needed
name = table2cell(info(:,1)); 
data = table2array(info(:,2));
%
for i = 1:length(name)
    % to get the blanks
    if contains(name(i), 'b')    
        blname{i,1} = name(i);
        blks(i,1) = data(i);
    end
    % to get the standards
    if contains(name(i),'0.0')  
        stname{i,1} = name(i);
        stds(i,1) = data(i); 
    end 
    % to get the samples
    if contains(name(i),'s') 
        sname{i,1} = name(i);
        samps(i,1) = data(i);
    end
end

blanks = [cell2table(blname) array2table(blks)];
blanks(blanks.blks == 0,:) = [];
% to get the offset value
ofset = mean(table2array(blanks(1:10,2)));
% first 10 blanks to get the detection limit
detectL = mean(table2array(blanks(1:10,2))) + 2*std(table2array(blanks(1:10,2)));


stads = [cell2table(stname) array2table(stds)];
stads(stads.stds == 0,:) = [];
standards = stads(~any(ismissing(stads),2),:);
cMg = [0.005; 0.015; 0.020; 0.025; 0.050]; % standards
begin = table2array(standards(1:2:10,2))-ofset;
dupli = table2array(standards(2:2:10,2))-ofset;
mid1 = [NaN NaN NaN table2array(standards(11,2))-ofset NaN]; % middle calibration after process blanks
mid2 = [NaN NaN NaN table2array(standards(12,2))-ofset NaN]; % middle calibration after sample 8
mid3 = [NaN NaN NaN table2array(standards(13,2))-ofset NaN]; % middle calibration after sample 16
mid4 = [NaN NaN NaN table2array(standards(14,2))-ofset NaN]; % middle calibration after sample 24
endi = table2array(standards(15:19,2))-ofset;
figure
plot(cMg,begin,'o');
hold on
plot(cMg,dupli,'o');
plot(cMg,mid1,'*');
plot(cMg,mid2,'*');
plot(cMg,mid3,'*');
plot(cMg,mid4,'*');
plot(cMg,endi,'o');
title('Cycle5 Mg^2^+ calibration')
xlabel('standards')
ylabel('absorbance')
xlim([0,0.052])
ylim([0,0.9])
legend('begin calibration','begin duplicate','mid 1','mid 2','mid 3','mid 4','end calibration','Location','southeast')
xticks([0.005 0.015 0.020 0.025 0.050])
xticklabels({'0.005','0.015','0.020','0.025','0.050'})
P =  polyfit(cMg,endi,1); % extract the equation
yP = P(1)*cMg + P(2); % predicted standards concentration
R2 = corr(endi,yP)^2; % calculated R-square


samples = [cell2table(sname) array2table(samps)];
samples(~samples.samps,:) = [];
DF = 68; % dilution factor
sA = (table2array(samples(1:3:end,2))+table2array(samples(2:3:end,2))+table2array(samples(3:3:end,2)))/3 - ofset;
sA(sA<detectL) = NaN; % absorbance should not lower than detection limit
sC = (sA - P(2))/P(1)*DF; % calculate the concentration of samples
sC(sC<0) = NaN; % sample concentration should not lower than 0
figure
plot((1:1:27)',log10(sC),'o');
xlim([0,27])
title('Cycle5 Mg^2^+ concentration')
xlabel('Number of samples')
ylabel('Log_1_0[M]')





