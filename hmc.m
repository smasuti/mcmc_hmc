% Hamiltonian Monte Carlo for linear forward problem with Leapfrog method. 
% Author : Sagar Masuti
% Date   : 15-May-2019
% -------------------------------------------------------------------------
rand('seed',12345);
randn('seed',12345);
 
% STEP SIZE
delta = 0.0001;
nsamples = 10000;
L = 500;
nd = 2;

m1=4; m2=2;
x=(0:0.1:5)';
dobs=(m1*x+m2+0.01);

gradu=@(m) G'*(dobs-G*m)-m;
gradk=@(p) p;

G=[x ones(length(x),1)];

%% HMC iteration
i=1;
mcur=[3.8 1.8]';
samples = zeros(nsamples,nd);

while(i < nsamples+1)    
    pcur = randn(2,1);    
    pnew = pcur;
    mnew = mcur;
    
    ucur = 0.5*(((dobs-G*mcur)')*(dobs-G*mcur)+(mcur'*mcur));
    kcur = pcur'*pcur/2;
    hcur = ucur + kcur;
    
    pnew = pnew - delta*gradu(mnew)/2;
    mnew = mnew + delta*gradk(pnew);
    
    for l=1:L-1
        pnew = pnew - delta*gradu(mnew);
        mnew = mnew + delta*gradk(pnew);
    end
    pnew = pnew - delta * gradu(mnew)/2;
    pnew = -pnew;

    unew = 0.5*(((dobs-G*mnew)')*(dobs-G*mnew)+(mnew'*mnew));
    knew = pnew'*pnew/2;
    hnew = unew + knew;
    if (rand <= exp(-(hnew-hcur)))
        mcur = mnew;
        samples(i,:) = mnew;
        i=i+1;
    end
    
end

%%
burnin=1000;
figure(1);clf;
subplot(2,2,1);
histogram(samples(burnin:end,1));
xlim([3.5 4.5]);
subplot(2,2,4);
histogram(samples(burnin:end,2));
xlim([1 3]);
subplot(2,2,3);
scatter(samples(burnin:end,1),samples(burnin:end,2));
box on
xlim([3.5 4.5]);
y=(1:0.1:3);
x=(3:0.1:5);
hold on
plot(m1*ones(length(y),1),y,'r--');
plot(x,m2*ones(length(x),1),'r--');
