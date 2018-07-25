function [L] = myfen(x,Pbiao,price,lambda,bsload,P_mft,Ntest)
temp=0;


    for j=1:96
        temp=temp+Pbiao*(15/60*price(j)+lambda(j))*x(j);
    end
    temp2=0;

for j=1:96
   temp2=temp2+lambda(j)*(bsload(j)-P_mft);
end
L=temp+temp2/Ntest;
end


