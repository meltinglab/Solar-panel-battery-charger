%% Transfer function

syms s H L C R CIN RP VIN VO VD I VP

H=(VO+VD)/(VIN+VO+VD);


% i vo vin ---- vp h
A=[0  -(1-H)/L  H/L;(1-H)/C  -1/(C*R) 0;-1/CIN 0 -1/(CIN*RP) ]
B=[0 (VIN+VO+VD)/L;0 -I/C; 1/(RP*CIN) 0]
D=[0];




%For i
Ci=[1 0 0];
Gi=Ci*(inv((s.*eye(3))-A))*B;


Gig=Gi(1)
[cnumig,cdenig]=zpsym2numden(Gig);

Gih=Gi(2)
[cnumih,cdenih]=zpsym2numden(Gih);



%For vo
Cvo=[0 1 0];
Gvo=Cvo*(inv((s.*eye(3))-A))*B;

Gvg=Gvo(1)
[cnumvg,cdenvg]=zpsym2numden(Gvg);

%SEPIC controlled by duty cycle( Charging at constant voltage)
Gvh=Gvo(2)
[cnumvh,cdenvh]=zpsym2numden(Gvh);


%Para vin
Cvin=[0 0 1];
Gvin=Cvin*(inv((s.*eye(3))-A))*B;

Gving=Gvin(1);
[cnumving,cdenving]=zpsym2numden(Gving);

Gvinh=Gvin(2)
[cnumvinh,cdenvinh]=zpsym2numden(Gvinh);

%

%Current Peak Mode Control
disp('Ahora analizamos el CPM para hallar la f.t vo/icontrol')
syms Ma Ts H L


M1=VIN/L

M2=-(VO+VD)/L

Ma=M2*0.55

Fm=1/(Ma*Ts+H*M1*Ts-(1-H)*M2*Ts)

Fg=(H^2)*Ts/(2*L)

Fv=((1-H)^2)*Ts/(2*L)


%vo/vp
Gvcpm=(Gvg*(1+Fm*(Gih+Fg*Gvinh))-Gvh*Fm*(Gig+Fg*Gving))/(1+Fm*(Gih+Fg*Gvinh-Fv*Gvh));
Gvcpm=simplify(Gvcpm);
[cnumvcpm,cdenvcpm]=zpsym2numden(Gvcpm);
disp('F.T vo/vp(Gvcpm)')
Gvcpm


%vo/
%SEPIC controlled by  Current peak mode control( Charging at constant voltage)
Gvc=(Fm*Gvh)/(1+Fm*(Gih+Fg*Gvinh-Fv*Gvh));
Gvc=simplify(Gvc);
[cnumvc,cdenvc]=zpsym2numden(Gvc);
disp('F.T vo/ic(Gvc)')
Gvc


%If the battery has not achieved its floating voltage, it will have to be
%charged at constant current:

%SEPIC controlled by  duty cycle( Charging at constant current)
Gioh=(1/R)*Gvh;
Gioh=simplify(Gioh);
[cnumioh,cdenioh]=zpsym2numden(Gioh);
disp('F.T io/h(Gioh)')
Gioh


%SEPIC controlado por CPM(Carga con corriente constante)
Gioc=(1/R)*Gvc;
Gioc=simplify(Gioc);
[cnumioc,cdenioc]=zpsym2numden(Gioc);
disp('F.T io/ic(Gioc)')
Gioc


%% Component values

function invocomp()
ESR=0.029; %ESR capacitors
RSH=0.1;    %Resistance shunt 
VO=14.7;    %Voltage output  
VIN=17.5;   %Voltage  input 
VD=0.45;    %Voltage forward diode
R=0.124;    % Resistance load (Rshunt+Rbattery)
VS=VO-1*R;      %Supply voltage model
CIN=56*10^-6;   %Input capacitor
RP=1.3323;      %Resistance panel


I=1.8657;     %Inductance current
H=0.4640;    %Duty Cycle(voltage equilibrium)
VP=19.9857; %Before drop voltage of resistor panel

f=100000;    %Switching frequency
Ts=1/f;      %Switching period

L=220*10^-6;   %Inductance
CX=56*10^-6;   %Capacitor coupling
C=56*10^-6;    %Capacitor output

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
%% Transfer fucntions replacing the selected components

disp('Transfer fucntions with components')

invocomp();

s=tf('s')

%vo/vp
disp('F.T vo/vp(Gvg)')
Gvgsys=tf(eval(cnumvg),eval(cdenvg))

%vo/h(Carga con voltaje constante)
disp('F.T vo/h(Gvd)')
Gvhsys=tf(eval(cnumvh),eval(cdenvh))

%i/vp
disp('F.T i/vp(Gig)')
Gigsys=tf(eval(cnumig),eval(cdenig))

%i/h
disp('F.T i/h(Gid)')
Gihsys=tf(eval(cnumih),eval(cdenih))

%Funciones CPM
disp('Now we analize the CPM to find the transfer function vo/icontrol')



M1=VIN/L

M2=-(VO+VD)/L

Ma=M2*0.55

Fm=1/(Ma*Ts+H*M1*Ts-(1-H)*M2*Ts)

Fg=(H^2)*Ts/(2*L)

Fv=-((1-H)^2)*Ts/(2*L)

Aramp=-(Ma*Ts)


%vo/vp
disp('F.T vo/vp(Gvcpm)')
Gvcpmsys=tf(eval(cnumvcpm),eval(cdenvcpm))



% vo/h(Charge at constant voltage) SEPIC controlled by duty cycle
disp('F.T vo/h(Charge at constant voltage) SEPIC controlled by duty cycle')
Gvhsys=tf(eval(cnumvh),eval(cdenvh))

% io/h(Carga con corriente constante) SEPIC controlado por ciclo útil
disp('F.T io/h (Charge at constant current ) SEPIC controlled by duty cycle')
Giohsys=tf(eval(cnumioh),eval(cdenioh))




%vo/ic(Carga con voltaje constante) SEPIC controlado por CPM
disp('F.T vo/ic(Charge at constant voltage) controlled by CPM')
Gvcsys=tf(eval(cnumvc),eval(cdenvc))

%io/ic(Carga con corriente constante) SEPIC controlado por CPM
disp('F.T io/ic(Charge at constant current) controlled by CPM')
Giocsys=tf(eval(cnumioc),eval(cdenioc))

