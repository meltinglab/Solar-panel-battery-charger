%% Transfer function

syms s H L C R CIN RP VIN VO VD I VP

H=(VO+VD)/(VIN+VO+VD);


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