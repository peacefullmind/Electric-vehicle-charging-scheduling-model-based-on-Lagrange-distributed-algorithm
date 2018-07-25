 %电动汽车个体智能充电单元
 %确定 拉格朗日乘子后，即可求出SS和L（i）
 SS=zeros(1,96);
 L=zeros(1,Ntest);
 %CO=zeros(1,Ntest);
 for i=1:Ntest
  %=========================================================================
   if (yesfirst(1,i)+yessec(1,i)==0)%均不充电
       SS(i,1:96)=0;
       x(1,1:96)=0;
      L(1,i)=myfen(x,Pbiao,price, lambda,bsload,P_mft,Ntest);
  %========================================================================= 
   elseif(yessec(1,i)==0)%第一次充电，第二次不充电
    hh= ceil(((SOC_end-SOC_sa(1,i))*Cbattery/Pcharge*4+1));%横向跨度
    x=zeros(1,96);
    y=1000000;
    for te=T1(1,i):T2(1,i)-hh
        x(1,1:te-1)=0;
        x(1,te:te+hh)=1;
        x(1,te+hh+1:96)=0;
        hanshu=myfen(x,Pbiao,price, lambda,bsload,P_mft,Ntest);
        if(hanshu<y)
            y=hanshu;
            SS(i,:)=x;
        end
    end
    L(1,i)=y;
%=========================================================================    
   elseif(yesfirst(1,i)==0)%第一次不充电，第二次充电
     hh= ceil(((SOC_end-SOC_sb(1,i))*Cbattery/Pcharge*4+1));%横向跨度
     xt=zeros(1,192);
     x=zeros(1,96);
     y=100000000000;
   for te=T3(1,i):32*4+1-hh
        xt(1,1:te-1)=0;
        xt(1,te:te+hh)=1;
        xt(1,te+hh+1:192)=0;
        
        x=xt(1,1:96)+xt(1,97:192);
        hanshu=myfen(x,Pbiao,price, lambda,bsload,P_mft,Ntest);
        if(hanshu<y)
            y=hanshu;
            myte=te;
            SS(i,:)=x;
        end
   end
    L(1,i)=y;
   %=========================================================================  
   else %两次均充电
   %第一次情况
   hh= ceil(((SOC_end-SOC_sa(1,i))*Cbattery/Pcharge*4+1));%横向跨度
   xa=zeros(1,96);
    y=1000000;
    for te=T1(1,i):T2(1,i)-hh
        xa(1,1:te-1)=0;  
        xa(1,te:te+hh)=1;
        xa(1,te+hh+1:96)=0;
        hanshu=myfen(xa,Pbiao,price, lambda,bsload,P_mft,Ntest);
        if(hanshu<y)
            y=hanshu;
            xa_jl=xa;
        end
    end
    %第二次情况
    hh= ceil(((SOC_end-SOC_sb(1,i))*Cbattery/Pcharge*4+1));%横向跨度
     xt=zeros(1,192);
    % x=zeros(1,96);
     y=1000000;
   for te=T3(1,i):32*4+1-hh
        xt(1,1:te-1)=0;
        xt(1,te:te+hh)=1;
        xt(1,te+hh+1:192)=0;
        
        x=xt(1,1:96)+xt(1,97:192);
        hanshu=myfen(x,Pbiao,price, lambda,bsload,P_mft,Ntest);
        if(hanshu<y)
            y=hanshu;
            xb_ju=x;
        end
   end
   x=xa_jl+xb_ju;
   L(1,i)=myfen(x,Pbiao,price, lambda,bsload,P_mft,Ntest);
   SS(i,:)=x; 
   end
 end
 