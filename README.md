# Solar-panel-battery-charger


'
## SUMMARY

This Project contributes to the development of DC-DC converters for projects with a greater focus on the conversion of renewable energy. We decided to use and analyze the **SEPIC** converter in cars for advantages that this topology offers such as: the insulation between the panel and the storage system and the characteristic of handling lower, equal, or greater voltages than the panel, the latter allows the panel to be easily changed to work with the same battery, making it flexible to the inputs and outputs of the system. In this project we will make a laboratory prototype as the initial phase of a possible product that can be commercialized and, therefore, has the possibility of being the basis for the creation of a company or used in the electronic devices in cars.



## Model Design

The V-model basically divides the development process into three sections: The decomposition on the left side of the V-model describes the transformation of requirements, which are presented as an input, into a system design. This leads to the second section of engineering in different disciplines, the domain-specific design process. The third section integrates the disciplines on the right side of the V-model during the system integration, verification and validation. The result or output of the V-model is a product. The model is supplemented by a bracket for modelling and model analysis, which begins and ends at the middle height of the two sides. Arrows between the two sides of the V-model illustrate the assurance of properties comprising verification and validation activities. Note, the assurance of properties is indicated right-to-left, which gives the impression of a retrospective process.

MIL, SIL, PIL and HIL testing come in the verification part of Model-Based Design approach after you have recognized the requirement of the component/system you are developing and they have been modeled in simulation level (e.g. Simulink platform). 

First, you have to develop a model of the actual Plant (hardware) in any simulation environment, for e.g. Simulink, which captures most of the important features of the hardware system. After the Plant model is created, we will develop the Controller model and verify if the Controller can control the Plant as per the requirement. This step is called Model-in-Loop (MIL) and you are testing the Controller logic on the simulated model of the plant. If your Controller works as desired, you should record the input and output of the Controller which will be used in the later stage of verification. 

Once your model is verified (i.e., MIL in the previous step is successful), the next stage is Software-in-Loop(SIL), where you generate code only from the Controller model and replace the Controller block with this code. Then run the simulation with the Controller block (which contains the C code) and the Plant, which is still the software model (similar to the first step). This step will give you an idea of whether your control logic i.e., the Controller model can be converted to code and if it is hardware implementable. You should log the input-output here and match with what you have achieved in the previous step. If you experience a huge difference in them, you may have to go back to MIL and make necessary changes and then repeat step 1 and 2. If you have a model which has been tested for SIL and the performance is acceptable you can move forward to the next step.

The next step is Processor-In-Loop (PIL) testing. In this step, we will put the Controller model onto an embedded processor/FPGA board and run a close loop simulation with the simulated Plant. So, we will replace the Controller Subsystem with a PIL block which will have the Controller code running on the FPGA board. This step will help you identify if the processor/FPGA board is capable of running the developed Control logic. If there are glitches, then go back to your code, SIL or MIL and rectify them.

Once your plant model has been verified using PIL, now you can replace the plant model with the original hardware, say lab model and run a test. 

As an added step, you can have a simulated plant model in a real-time PC before interfacing with the actual hardware, for example, in Speedgoat where you will run the plant model in real-time but have proper Analog/CAN communications between the Plant and Controller which you will be using while interfacing with the plant hardware. This step is known as HIL testing and the controller is typically on a production board/controller. This will help you with identifying issues related to the communication channels for example attenuation and delay which are introduced by an analog channel and can make the controller unstable if they are not captured in the simulation. This step is typically done to test safety critical application e.g. air bag deployment.

![Image of V-Model](/images/v_model.jpg)



## Hardware

##### Photovolatic Effect

The energy that a panel can deliver depends on the photons that fall on the surface of the panel; These are absorbed and produce a flow of electrons when each photon delivers the energy it has. Solar panels are made up of multiple photovoltaic cells which transform energy from sunlight into electrical energy.
These cells are capable of generating voltages, currents and power, which are determined by the level of radiation it receives in units of (W / m2) and temperature. The behavior of the photovoltaic effect that occurs in the panels is defined by the V ∗ I curves under different operating conditions. [1] [2] [3] [4]

![Image of V-Model](/images/solar_panel1.png)



##### Solar Panel

The voltage input to our SEPIC circuit will be a 17.5V 20W solar panel. The specifications of this are seen below in Figure below:

![Image of V-Model](/images/solar_panel2.png)

![Image of V-Model](/images/solar_panel3.png)

![Image of V-Model](/images/solar_panel4.png)



##### DC-DC SEPIC CONVERTER

The Single-Ended Primary-Inductance Converter (SEPIC) is a DC-DC converter which delivers an output voltage greater than or equal to the input voltage. Its topology consists of two inductances, two capacitors, a diode and a switch whose duty cycle modifies the average output voltage, which we will demonstrate in a later analysis.



The converter topology can be seen in figure below

![Image of V-Model](/images/SEPIC1.png)



##### SEPIC Analysis

Because the inductances in the SEPIC converter can be replaced by a coupled transformer to increase the efficiency and the available area on the printed circuit, we will use a transformer with a 1: 1 turn ratio whose model It is an ideal parallel transformer with a magnetizing inductance. Figure below demonstrates efficiency comparison with coupled and decoupled inductors Taking into account the above, our circuit is as follows:

![Image of V-Model](/images/SEPIC2.png)



Because our goal is to power the drive with a solar panel, we will use a decoupling capacitor parallel to the input in order to decouple the panel impedance and thus model the input as a constant voltage source. For the load and input we will use the corresponding models of our project for a proper analysis: the load of the converter is a battery (voltage source in series with a resistor) and the input is a solar panel (voltage source in series with resistor). 

The switching will be done by a MOSFET transistor whose gate signal will control its opening and closing.

With the proposed modifications, the converter with which the project will be developed is the following:

![Image of V-Model](/images/SEPIC3.png)



##### Input Capacitor

In a SEPIC converter, you have a triangular, continuous input current wave. So the inductor ensures that the input capacitor sees a relatively low current ripple, this input capacitor allows for less ripple fluctuation of voltage at the input, allowing it to stay close to the maximum power point and at the same time allowing the panel to be seen as an ideal source of voltage.



##### Selection of Power MOSFET

The parameters for the selection of the MOSFET are the minimum threshold voltage VTH (min), the ignition resistance RDS (ON), the Gate-Drain QGD load and the maximum voltage of Drain-Source VDS (max): Logically the MOSFET must be used based on the Gate voltage.

The peak switching voltage is the sum of the input and output voltage. The peak switching current is given by:

I<sub>M1(pico)</sub> = I<sub>L1(pico)</sub> + I<sub>L2(pico)</sub> = 2.07<sub>(pico)</sub>



##### Diode

The output diode must be able to withstand the peak switching current and the reverse VRD voltage.

A Schottky diode is used to take advantage of its low forward voltage (VM = 475mV), speed and ability to minimize efficiency losses.

The peak current passing through the diode is the same as the peak current of the drain mosfet. Peak Idrain = 3,003A



##### Driver

The Diver is in charge of sending a signal to the GATE of the MOSFET, replicating the switching signal to control the on and off of the latter. In our application we will only use 3 inputs to control the driveroutput: the logic supply voltage greater than 3V (VDD), logic input to control the gate controller low output (LIN) and supply voltage (VCC). The Driver must deliver at its LO output the logical signal it receives from LIN with the amplitude of VCC. One of the advantages of this gate driver is that it allows to deliver a control signal (PWM) to the GATE with a voltage and current that the MOSFET needs to generate the commutation.



##### Source

We decided to implement a regulated and isolated source to feed both systems autonomously without the need for line power.

The converter receives the battery output voltage (12V) filtered by an LC filter. This isolated, regulated, and dual output source delivers ± 5V and ± 600mA with 85% efficiency.



## Control

##### PROGRAMMED PEAK CURRENT CONTROL WITH COMPENSATION RAMP (PCPM):

We  will use programmed current control due to greater stability and control of the plant.

The block diagram in this figure describes the operation of the current control with compensation ramp, this controls the signal from the gate of the MOSFET, that is, our PWM; In this system each clock cycle, the output "Q" of the flip-flop is high until the reset "R" is activated in hTs, this happens when the input signal (current flowing through the inductance) is equal to value of the artificial ramp at that time. 

![Image of V-Model](/images/ctrl1.png)

![Image of V-Model](/images/ctrl2.png)



This plot shows the artificial ramp

![Image of V-Model](/images/ctrl3.png)



And this plot shows the Inductance current behavior and compensation ramp

![Image of V-Model](/images/ctrl4.png)



## MPPT

An MPPT, or maximum power point tracker is an electronic DC to DC converter that optimizes the match between the solar array (PV panels), and the battery bank or utility grid. To put it simply, they convert a higher voltage DC output from solar panels (and a few wind generators) down to the lower voltage needed to charge batteries.

The major principle of MPPT is to extract the maximum available power from PV module by making them operate at the most efficient voltage (maximum power point). That is to say:

MPPT checks output of PV module, compares it to battery voltage then fixes what is the best power that PV module can produce to charge the battery and converts it to the best voltage to get maximum current into battery. It can also supply power to a DC load, which is connected directly to the battery.

MPPT is most effective under these conditions:

* Cold weather, cloudy or hazy days: Normally, PV module works better at cold temperatures and MPPT is utilized to extract maximum power available from them.
* When battery is deeply discharged: MPPT can extract more current and charge the battery if the state of charge in the battery is lowers.



A MPPT solar charge controller is the charge controller embedded with MPPT algorithm to maximize the amount of current going into the battery from PV module.

MPPT is DC to DC converter which operates by taking DC input from PV module, changing it to AC and converting it back to a different DC voltage and current to exactly match the PV module to the battery.

In any applications which PV module is energy source, MPPT solar charge controller is used to correct for detecting the variations in the current-voltage characteristics of solar cell and shown by I-V curve.

This controller is necessary for any solar power systems need to extract maximum power from PV module; it forces PV module to operate at voltage close to maximum power point to draw maximum available power.

MPPT solar charge controller allows users to use PV module with a higher voltage output than operating voltage of battery system. For example, if PV module has to be placed far away from charge controller and battery, its wire size must be very large to reduce voltage drop. With a MPPT solar charge controller, users can wire PV module for 24 or 48 V (depending on charge controller and PV modules) and bring power into 12 or 24 V battery system. This means it reduces the wire size needed while retaining full output of PV module.

MPPT solar charge controller reduces complexity of system while output of system is high efficiency. Additionally, it can be applied to use with more energy sources. Since PV output power is used to control DC-DC converter directly. Also, these controllers can be applied to other renewable energy sources such as small water turbines, wind-power turbines, etc.



-------------

----



##### Authors:

- Armando Ruben Villar Tovar				877990
- Hamed Shoushtaridehshal                   878009 
- Jaber Nikpouri                                         878189
- 0
