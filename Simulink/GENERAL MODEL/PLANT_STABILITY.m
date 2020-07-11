%% Function transfer analysis

syms s H L C R CIN RP VIN VO VD I VP

H=(VO+VD)/(VIN+VO+VD);

% i vo vin ---- vp h
A=[0  -(1-H)/L  H/L;(1-H)/C  -1/(C*R) 0;-1/CIN 0 -1/(CIN*RP) ]
B=[0 (VIN+VO+VD)/L;0 -I/C; 1/(RP*CIN) 0]
D=[0];


% i
Ci=[1 0 0];
Gi=Ci*(inv((s.*eye(3))-A))*B;


Gig=Gi(1)
[cnumig,cdenig]=zpsym2numden(Gig);

Gih=Gi(2)
[cnumih,cdenih]=zpsym2numden(Gih);



% vo
Cvo=[0 1 0];
Gvo=Cvo*(inv((s.*eye(3))-A))*B;

Gvg=Gvo(1)
[cnumvg,cdenvg]=zpsym2numden(Gvg);

%SEPIC controlled by duty cycle(Char at constant voltage)
Gvh=Gvo(2)
[cnumvh,cdenvh]=zpsym2numden(Gvh);


% vin
Cvin=[0 0 1];
Gvin=Cvin*(inv((s.*eye(3))-A))*B;

Gving=Gvin(1);
[cnumving,cdenving]=zpsym2numden(Gving);

Gvinh=Gvin(2)
[cnumvinh,cdenvinh]=zpsym2numden(Gvinh);

%


% CPM control
disp('Analyse CPM to find  transfer function of vo/icontrol')
syms Ma Ts H L


M1=VIN/L

M2=-(VO+VD)/L

Ma=M2*0.55

Fm=1/(Ma*Ts+H*M1*Ts-(1-H)*M2*Ts)

Fg=(H^2)*Ts/(2*L)

Fv=((1-H)^2)*Ts/(2*L)

%Control Transfer functions:

%vo/vp
Gvcpm=(Gvg*(1+Fm*(Gih+Fg*Gvinh))-Gvh*Fm*(Gig+Fg*Gving))/(1+Fm*(Gih+Fg*Gvinh-Fv*Gvh));
Gvcpm=simplify(Gvcpm);
[cnumvcpm,cdenvcpm]=zpsym2numden(Gvcpm);
disp('F.T vo/vp(Gvcpm)')
Gvcpm

% 1st Case of constant voltage charge comtrolling current of CPM
%vo/ic
Gvc=(Fm*Gvh)/(1+Fm*(Gih+Fg*Gvinh-Fv*Gvh));
Gvc=simplify(Gvc);
[cnumvc,cdenvc]=zpsym2numden(Gvc);
disp('F.T vo/ic(Gvc)')
Gvc

%2nd case of chargeing the battery with constant current by controlling
%duty cycle. This occurs when the battery has not reached the floating
%voltage; therefore, it will hace to be charged with constant current in
%the plant
Gioh=(1/R)*Gvh;
Gioh=simplify(Gioh);
[cnumioh,cdenioh]=zpsym2numden(Gioh);
disp('F.T io/h(Gioh)')
Gioh


%Constant  current charge controlled by cpm
Gioc=(1/R)*Gvc;
Gioc=simplify(Gioc);
[cnumioc,cdenioc]=zpsym2numden(Gioc);
disp('F.T io/ic(Gioc)')
Gioc

%% Transfer functions with component values

disp('Transfer functions with component values')

invocomp();

s=tf('s')

%vo/vp
Gvgsys=tf(eval(cnumvg),eval(cdenvg))

%vo/h(Carga con voltaje constante)
Gvhsys=tf(eval(cnumvh),eval(cdenvh))

%i/vp
Gigsys=tf(eval(cnumig),eval(cdenig))

%i/h
Gihsys=tf(eval(cnumih),eval(cdenih))

%CPM control functions



M1=VIN/L
M2=-(VO+VD)/L
Ma=M2*0.55
Fm=1/(Ma*Ts+H*M1*Ts-(1-H)*M2*Ts)
Fg=(H^2)*Ts/(2*L)
Fv=-((1-H)^2)*Ts/(2*L)

Aramp=-(Ma*Ts)


%vo/vp
Gvcpmsys=tf(eval(cnumvcpm),eval(cdenvcpm))

% vo/h Constant voltage charge controlled by duty cycle 
Gvhsys=tf(eval(cnumvh),eval(cdenvh))

% io/h Constant current charge controlled by duty cycle 
Giohsys=tf(eval(cnumioh),eval(cdenioh))

%vo/ic Constant voltage  charge controlled by CPM
Gvcsys=tf(eval(cnumvc),eval(cdenvc))

%io/ic Constant current charge controlled by duty cycle  CPM
Giocsys=tf(eval(cnumioc),eval(cdenioc))



%% Plant selection

%Add a delay and discretize to work on the plant 

%Voltaje cons.
Gvcsysret=tf(eval(cnumvc),eval(cdenvc),'InputDelay',Ts);
Gvcsyszoh=c2d(Gvcsysret,1/f,'zoh')

%Current cons.
Giocsysret=tf(eval(cnumioc),eval(cdenioc),'InputDelay',Ts);
Giocsyszoh=c2d(Giocsysret,1/f,'zoh')

opts = bodeoptions('cstprefs');
opts.FreqUnits = 'kHz';

%%
%Time delay to limit duty cycle
LimH=0.95;
Td=(LimH)*Ts;

%%
%Estability analysis depending on the component tolerance
syms s
invocomp();

%Loop to find all plants with differen errors of -30%,0% y +30%
var=1;
porc=0.3;

for(a=1:1:3)
    Laux=L+L*(a-2)*porc;

    for(b=1:1:3)
        Caux=C+C*(b-2)*porc;
        
            for(c=1:1:3)
                Cinaux=CIN+CIN*(c-2)*porc;               
                    
                    for(d=1:1:3)
                        VPaux=VP+VP*(d-2)*porc;
                        
                        for(e=1:1:3)       
                            VOaux=VO+VO*(e-2)*porc;



                            %Parameter change
                            L=Laux;
                            C=Caux;
                            CIN=Cinaux;
                            VO=VOaux;
                            VS=VO-1*R;
                            VP=VPaux;
                            VIN=VP-I*RP;
                            H=(VO+VD)/(VIN+VO+VD);
                            
                            %Create a plant with modified components
                            
                            %(Voltaje cons)
                            sysv=tf(eval(cnumvc),eval(cdenvc),'InputDelay',Ts);
                            syszohv=c2d(sysv,1/f,'zoh');
                            
                            %(Current cons)
                            sysi=tf(eval(cnumioc),eval(cdenioc),'InputDelay',Ts);
                            syszohi=c2d(sysi,1/f,'zoh');
                            
                            
                            
                            %Save the plant in the array containing all combinations  
                            
                            %(Voltaje cons)
                            PLANTASv(var)=syszohv;
                            %(Current cons)
                            PLANTASi(var)=syszohi;
                            
                            
                            %Gain phase and frequencies 
                            [Gmv(var),Pmv(var),Wcgv(var),Wcpv(var)] = margin(syszohv);
                            Gmv(var)=20*log10(Gmv(var));
                            
                            [Gmi(var),Pmi(var),Wcgi(var),Wcpi(var)] = margin(syszohi);
                            Gmi(var)=20*log10(Gmi(var));
                            
                            
                            
                            %Counter
                            var=var+1; 
                            invocomp();
                        end
                    
                end
            end
    end
end

%Minimun phase and gain
[minGmv,minGmvarv]=min(Gmv);
[minPmv,minPmvarv]=min(Pmv);

[minGmi,minGmvari]=min(Gmi);
[minPmi,minPmvari]=min(Pmi);


%For plants with worst gain
sysacompensargainv=PLANTASv(minGmvarv);
sysacompensargaini=PLANTASi(minGmvari);

%For plants with worst phase
sysacompensarfasev=PLANTASv(minPmvarv);
sysacompensarfasei=PLANTASi(minPmvari);

%%

%(Import contol from PI folders)

[Kp,Ki,Kd,Tf,Tm]=piddata(PICi)
[Kpv,Kiv,Kdv,Tf,Tm]=piddata(PICv)
%Used pidTuner to determine phase above 59 and gain above 25dB 

%%

disp('Select control')
PICv
PICi


%%
invocomp()

%%


%Extract numerator and denominator 
function [numsym,densym]=zpsym2numden(F)
syms s z

[num,den]=numden(F);

numsymm=coeffs(num,s);
numsym=fliplr(numsymm);

densymm=coeffs(den,s);
densym=fliplr(densymm);

end

%Component values selected at input and output calculations
function invocomp()
ESR=0.029; %ESR capacitor
RSH=0.1;    %Resistor shunt 
VO=14.7;    %Voltage output equilibrium  
VIN=17.5;   %Voltage input equilibrium
VD=0.45;    %Voltage  forward diode
R=0.124;    % Resistance load (Rshunt+Rbattery)
VS=VO-1*R;      %Supply voltage model
CIN=56*10^-6;   %Capacitor input
RP=1.3323;      %Resistor panel

I=1.8657;     %Inductor current equi
H=0.4640;    %Duty cycle voltage equilibrium
VP=19.9857; %Behore voltage drop of panel resistor

f=100000;    %Switching frequency
Ts=1/f;      %Switching period

L=220*10^-6;   %Inductance of transformer
CX=56*10^-6;   %Coupling capacitor
C=56*10^-6;    %Output capacitor

assignin('base','VO',VO)
assignin('base','VP',VP)
assignin('base','VD',VD)
assignin('base','VS',VS)
assignin('base','VIN',VIN)
assignin('base','R',R)
assignin('base','RSH',RSH)
assignin('base','ESR',ESR)
assignin('base','H',H)
assignin('base','I',I)
assignin('base','CIN',CIN)
assignin('base','RP',RP)
assignin('base','f',f)
assignin('base','Ts',Ts)
assignin('base','L',L)
assignin('base','CX',CX)
assignin('base','C',C)

end