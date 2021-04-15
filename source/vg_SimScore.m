function SS=vg_SimScore(syll1,syll2,fs)

%This function returns the Similarity Score between 2 sylls;
%SS is computed both as dot product and euclidean distance between the
%feature vectors;

[features labels] = SAPfeatures(syll1,fs);

%Below vals for normalization
vector{1}.name='AM';vector{1}.mdn=0;vector{1}.mad=.127;
vector{2}.name='FM';vector{2}.mdn=44.1;vector{2}.mad=22.6;
vector{3}.name='Entropy';vector{3}.mdn=-2.23;vector{3}.mad=.79;
vector{4}.name='VarEnt';vector{4}.mdn=.34;vector{4}.man=.4;
vector{5}.name='Pgood';vector{5}.mdn=264.2;vector{5}.mad=190.82;
vector{6}.name='MeanFrequency';vector{7}.mdn=3799;vector{7}.mad=1001;
vector{7}.name='VarPgood';vector{6}.mdn=25100;vector{6}.mad=75795;


%%Below are the SAP medians and MADs for normalization
%SYLL-1: subtract the median divide by the MAD
a(1)=(median(features{1})-0)/.127;%AM
a(2)=(median(features{2})-44.1)/22.6;%FM
a(3)=(median(features{3})--2.23)/.79;%Entropy
a(4)=(var(features{3})-.34)/.4;%Entropy Variance
a(5)=(median(features{5})-264.2)/190.82;%PitchGoodness
a(6)=(mean(features{6})-3799)/1001;%MeanFrequency
a(7)=(var(features{5})-25100)/75795;%VarPitchGoodness

features=SAPfeatures(syll2,fs);
b(1)=(median(features{1})-0)/.127;%AM
b(2)=(median(features{2})-44.1)/22.6;%FM
b(3)=(median(features{3})--2.23)/.79;%Entropy
b(4)=(var(features{3})-.34)/.4;%Entropy Variance
b(5)=(median(features{5})-264.2)/190.82;%PitchGoodness
b(6)=(mean(features{6})-3799)/1001;%MeanFrequency
b(7)=(var(features{5})-25100)/75795;%VarPitchGoodness

%Below is the xcorr and euclidean distance method for extracting SS.
[xx lags]=xcorr(a,b,'coeff');
%SS.cc=dot(a,b);%the dot product where a and b are the vectors of features for sylls 1 and 2;
%figure;plot(a);hold on;plot(b,'r');
lag0=find(lags==0);
SS.cc=xx(find(lags==0));
SS.euclid=sqrt(sum((a-b).^2));