# Quartus에서의 논리회로 시뮬레이션 (회로도)
Simulating Logic Circuits in Quartus by using Schematic Design

[2_3_Quartus II(Schematic)를 이용한 순차논리회로 실험](https://docs.google.com/document/d/18B2oY9i0UkC5DJaRiA0vmYNfsSaPw23wI-6OQMqPB7Y/edit#heading=h.754qeavoagw5)

## 예제
1. 기본 FlipFlop 예제 (Basic FlopFlop)

    + 1.1  [SR Latch](Basic_FilpFlop_ExampleCollection/SR_Latch) (SR Latch)
        ![SR_Latch](Basic_FilpFlop_ExampleCollection/SR_Latch/SR_Latch.png)
        ![SR_Latch_vwf_simulation](Basic_FilpFlop_ExampleCollection/SR_Latch/SR_Latch_vwf_simulation.png)

    + 1.2  [기본 FlipFlop](Basic_FilpFlop_ExampleCollection/Total_FF_ExampleCollection(SR,JK,D,T)) (Basic FlipFlop)
        ![Total_FF_ExampleCollection_schematic](Basic_FilpFlop_ExampleCollection/Total_FF_ExampleCollection(SR,JK,D,T)/Total_FF_ExampleCollection_schematic.png)
        ![Total_FF_ExampleCollection_vwf_simulation]() 

    + 1.3  [Master-Slave F/F](Basic_FilpFlop_ExampleCollection/MasterSlave_SR_FF) (Master-Slave F/F)
        ![MasterSlave_SR_FF_schematic](Basic_FilpFlop_ExampleCollection/MasterSlave_SR_FF/MasterSlave_SR_FF_schematic.png)
        ![MasterSlave_SR_FF_vwf_simulation]() 

    + 1.4  [Master-Slave F/F (Ver.Subblock)](Basic_FilpFlop_ExampleCollection/MasterSlave_SR_FF(Ver.Subblock)) (Master-Slave F/F (Ver.Subblock))
        ![MasterSlave_SR_FF(Ver.Subblock)_schematic](Basic_FilpFlop_ExampleCollection/MasterSlave_SR_FF(Ver.Subblock)/MasterSlave_SR_FF(Ver.Subblock)_schematic.png)
        ![MasterSlave_SR_FF(Ver.Subblock)_vwf_simulation]()

    + 1.5  [F/F 응용- Debounce](Basic_FilpFlop_ExampleCollection/Debounce_Circuit) (Debouncing Circuit)
        ![Debounce_Circuit_schematic](Basic_FilpFlop_ExampleCollection/Debounce_Circuit/Debounce_Circuit_schematic.png)
        ![Debounce_Circuit_vwf_simulation]()
    
2.  레지스터 (Register)

    + 2.1 [SISO 레지스터](SISO_Register/SISO_Register.zip) (Serial Input Serial Output Register)
        ![SISO_Register_schematic](SISO_Register/SISO_Register_schematic.png)
        ![_vwf_simulation](_vwf_simulation.png)
        ![_schematic](_schematic.png)
        ![_vwf_simulation](_vwf_simulation.png)

        + 2.1.1 [8비트 SISO 레지스터](SISO_Register/8-bits_SISO_Register.zip) (8-bits SISO Register)
            ![8-bits_SISO_Register_schematic](SISO_Register/8-bits_SISO_Register_schematic.png)
            ![_vwf_simulation](_vwf_simulation.png)

    + 2.2 [SIPO 레지스터](SIPO_Register/SIPO_Register.zip) (Serial Input Parallel Output Register)
        ![SIPO_Register_schematic](SIPO_Register/SIPO_Register_schematic.png)
        ![_vwf_simulation](_vwf_simulation.png)
    
    + 2.3 [레지스터 응용-디지털 금고](Digital_StrongBox/Digital_StrongBox.zip) (Digital Locker)
        ![Digital_StrongBox_schematic](Digital_StrongBox/Digital_StrongBox_schematic.png)
        ![_vwf_simulation](_vwf_simulation.png)

    + 2.4 [레지스터 응용-난수 발생 회로](RandomNumber_Generator/RandomNumber_Generator.zip) (Random Number Generator)
        ![RandomNumber_Generator_schematic](RandomNumber_Generator/RandomNumber_Generator_schematic.png)
        ![_vwf_simulation](_vwf_simulation.png)


3. n비트 카운터 (n-bits counter)

    + 3.1 [2비트 카운터](2bits_Counter/2bits_counter.zip) (2 bits counter)
        ![2bits_counter](2bits_Counter/2bits_counter.png)
        ![2bits_counter_SimulationCaptured](2bits_Counter/2bits_counter_SimulationCaptured.JPG)

    + 3.2 [3비트 카운터](3bits_Counter/3bits_counter.zip) (3 bits counter)
        ![3bits_counter](3bits_Counter/3bits_counter.png)
        ![3bits_counter_SimulationCaptured](3bits_Counter/3bits_counter_SimulationCaptured.JPG)
     
    + 3.3 [3비트 Ripple 카운터](3bit_ripple) (3 bits Ripple counter)
        ![_schematic](_schematic.png)
        ![_vwf_simulation](_vwf_simulation.png)  
        
    + 3.5  [3비트 Up/Down 카운터](3bits_UpDown_Counter/3bits_updown_counter.zip) (3 bits Up/Down counter)
        ![사진]()
        ![3bits_updown_counter_SimulationCaptured](3bits_UpDown_Counter/3bits_updown_counter_SimulationCaptured.JPG)  

    + 3.6  [4비트 카운터](4bits_Counter/4bits_counter.zip) (4 bit counter)
        ![사진]()
        ![4bits_counter_SimulationCaptured](4bits_Counter/4bits_counter_SimulationCaptured.JPG) 

    + 3.7  [Modulo-m Ripple 카운터](Modulo-m_ripple_counter/Modulo-m ripple counter.zip) (Modulo-m Ripple counter)
        ![_schematic](_schematic.png)
        ![_vwf_simulation](_vwf_simulation.png)

    + 3.8  [BCD 카운터](BCD_Counter/BCD_counter.zip) (Binary Coded Decimal counter)
        ![사진]() 
        ![BCD_counter_SimulationCaptured](BCD_Counter/BCD_counter_SimulationCaptured.JPG)
    
    + 3.9  [Ripple up 카운터](Ripple up counter/Ripple up counter.zip) (Ripple up counter)
        ![_schematic](_schematic.png)
        ![_vwf_simulation](_vwf_simulation.png)

    + 3.10  [Ripple down 카운터](Ripple down counter/Ripple down counter.zip) (Ripple down counter)
        ![_schematic](_schematic.png)
        ![_vwf_simulation](_vwf_simulation.png)

    + 3.7  [Ripple up down 카운터](Ripple up down counter/Ripple up down counter.zip) (Ripple up down counter)
        ![_schematic](_schematic.png)
        ![_vwf_simulation](_vwf_simulation.png)

4. 순차회로 예제 (Sequential Logic Circuit Example)

    + 4.1 [순차회로 예제](Sequential logic circuit example/Seq_exam.zip) (Sequential Logic circuit example)
        ![_schematic](_schematic.png)
        ![_vwf_simulation](_vwf_simulation.png)

5. 순차회로 설계 (Sequential Logic Circuit Design)   

    + 5.1 [순차회로 설계](Design_Sequential_Circuit/Design_Sequential_Circuit.zip) (Sequential Logic Circuit Design)
        ![사진]()
        ![Simulation_Captured_Pictures](Design_Sequential_Circuit/Simulation_Captured_Pictures.JPG)
         

