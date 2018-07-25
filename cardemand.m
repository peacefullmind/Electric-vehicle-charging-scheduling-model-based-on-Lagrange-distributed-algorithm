%利用蒙特卡洛模拟法模拟出电动汽车负荷曲线
%同时求解出无序充电功率曲线，作为有序充电曲线的对比基础
clc;clear;
Ntest=100;%仿真程序 车辆数
SOC_end=0.9;
Pbiao=15;%充电功率为15kW
nn=0.9;%充电效率为0.9
Pcharge=Pbiao*nn;%实际充电的功率
Cbattery=30;                     %电池容量
distance=unifrnd(30,80,1,Ntest);     %Ntest辆车 每辆车的单程距离
judge=0.15*distance/Cbattery;            %单程耗电SOC

SOC=rand(1,Ntest).*(1-judge)+judge;          %初始SOC
timestart=8;                     %8点离家
timework=normrnd(8.5,0.5,1,Ntest);          %到班时间，服从正态分布
timerest=normrnd(17.5,0.5,1,Ntest);         %下班时间
timehome=normrnd(19,0.5,1,Ntest);           %到家时间，由于上下班高峰路况复杂，所以不认为下班回家耗时与上班耗时相同



SOC=SOC-judge;
battery=SOC*Cbattery;    %到班后的电量
time1=zeros(1,Ntest);
time2=zeros(1,Ntest);
%SOC记录数组
SOC_sa=ones(1,Ntest);
SOC_sb=ones(1,Ntest);

for i=1:Ntest
    if SOC(i)<judge+0.2
        SOC_sa(i)=SOC(i);
        time1(i)=timework(i);           %到班后需要充电，充电开始时间为到班时间
        time2(i)=time1(i)+(1-SOC(i))*Cbattery/Pcharge;     %充电结束时间，充电功率Pcharge
        SOC(i)=SOC_end;                              %下班前充满电
        battery(i)=Cbattery*SOC(i);
    end
end

SOC=SOC-judge;
battery=SOC*Cbattery;    %到家后的电量
time3=zeros(1,Ntest);
time4=zeros(1,Ntest);

for i=1:Ntest
    if SOC(i)<max(judge,0.4)
        SOC_sb(i)=SOC(i);
        time3(i)=timehome(i);           %到家后需要充电，充电开始时间为到班时间
        time4(i)=time3(i)+(1-SOC(i))*Cbattery/Pcharge;     %充电结束时间，充电功率4KW
        SOC(i)=SOC_end;                              %第二天8点前可以充满电
        battery(i)=Cbattery*SOC(i);
    end
end


time=0:0.1:48;
Ycharge=zeros(1,481);
roundn(time1,-1);
roundn(time2,-1);
roundn(time3,-1);
roundn(time4,-1);

 for i=1:Ntest
     if (time2(i)-time1(i)~=0)
         kstart=round(10*time1(i)+1);
         kend=round(10*time2(i)+1);
        Ycharge(1,kstart:kend)=Ycharge(1,kstart:kend)+1;
     end
     if (time4(i)-time3(i)~=0)
         kstart=round(10*time3(i)+1);
         kend=round(10*time4(i)+1);
        Ycharge(1,kstart:kend)=Ycharge(1,kstart:kend)+1;
     end
 end
 temp=Ycharge(1:241)+Ycharge(241:481);
 x=0:0.1:24;
 xx=0:0.05:24;
 tempp = interp1(x,temp,xx,'linear');
 Pwuxu=tempp(1:5:481)*Pbiao;
%=========================================================================
%原电网基础负荷
 bsload=1.5*xlsread('baseload',1,'B2:CT2');
 Swuxu=bsload+Pwuxu;
 xt=0:0.25:24;
 plot(xt,bsload,xt,Swuxu);
 %plot(xt,Pwuxu);
 legend('电网原负荷','叠加无序充电负荷后');
 xlabel('时间/h');
 ylabel('负荷/kW');
 
   %=========================================================================
 %解有序充电模型
 
 %分时电价赋值
 price=zeros(1,96);
 for j=1:33-1
     price(j)=0.365;%谷电价0.365元/kWh 
 end
 for j=33:4*8+1-1
     price(j)=0.869;%峰电价   元/kWh 
 end
  for j=4*8+1:4*17+1-1
     price(j)=0.687;%平电价   元/kWh 
  end
  for j=4*17+1:4*21+1-1
     price(j)=0.869;%峰电价   元/kWh 
  end
 for j=4*21+1:4*24+1-1
     price(j)=0.687;%平电价   元/kWh 
 end
 
 deltaT=15/60;%15min折算成小时
 cost=0;%购电电价
 
 S=zeros(Ntest,96);
 %充电开始时间折算成96点形式
 J1=zeros(1,Ntest);
 J2=zeros(1,Ntest);
 J3=zeros(1,Ntest);
 J4=zeros(1,Ntest);
 for temp=1:Ntest
    J1(temp) =round(4*time1(temp)+1);
    J2(temp) =round(4*time2(temp)+1);
    J3(temp) =round(4*time3(temp)+1);
    J4(temp) =round(4*time4(temp)+1);
 end
 
 %是否充电记录数组 1表示充电
 yesfirst=zeros(1,Ntest);
 yessec=zeros(1,Ntest);
%S（ij）赋初值 也就是无序充电初值 
 for i=1:Ntest
    %到达单位后的充电情况
   if(J2(i)-J1(i)~=0)
       yesfirst(1,i)=1;
       jstart=J1(i);
       jend=J2(i);
       for temp=jstart:jend
           S(i,temp)=1;
       end
   end
   %下班后充电情况
     if(J4(i)-J3(i)~=0)
       yessec(1,i)=1;
       jstart=J3(i);
       jend=J4(i);
       for temp=jstart:jend
           S(i,temp)=1;
       end
     end
 end
 
 P_mft=5087;%最大允许负荷5087kW
 cost_wuxu=0;
 for i=1:Ntest
     for j=1:96
         cost_wuxu=cost_wuxu+Pbiao*S(i,j)*deltaT*price(j);
     end
 end
 
 T1=round(timework*4+1);
 T2=round(timerest*4+1);
 
 T3=round(timehome*4+1);
 
 S_yx=zeros(Ntest,96);
  %SS=S; 
 
  lambda=0.1*ones(1,96);%拉格朗日乘子初值
  v=1;
  obj=10000000000000000;%初值足够大
  jingdu=0.1;
  a=1;
  b=0.1;
  die=100;
  
  while((v<4)&&(die>jingdu))
      
    L=zeros(1,Ntest);
    x=zeros(1,96); 
    SS=zeros(Ntest,96);
    %执行智能充电单元
    run('ZN.m');  
    myk=1/(a+b*v);
    temp=5087*ones(1,96);
    mybsload=bsload(1,1:96);
    myh=mybsload+Pcharge*sum(S_yx)-temp;
    Tlambda=lambda;
     lambda=lambda+myk*myh/norm(myh);
    die=norm(lambda-Tlambda,2)/norm(Tlambda);
     v=v+1;
  end
  
  PSS=zeros(1,97);
  PSS(1,1:96)=sum(SS)*Pbiao;
  PSS(1,97)=PSS(1,1);
  
  Syouxu=bsload+PSS;
   xt=0:0.25:24;
  plot(xt,bsload,xt,Swuxu,'r:',xt,Syouxu,'g');
  legend('电网原负荷','叠加无序充电负荷后','叠加有序充电负荷后');
  xlabel('时间/h');
  ylabel('负荷/kW');
  

  
 
  
  
  
  

 
 
 
 
 
 
 
 
 


 
 
 











