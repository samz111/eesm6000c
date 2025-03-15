# FIR Structure

Main components:
1. One FSM
2. Two 32bit x 11 depth memories
    -> The memory is byte addressable
3. Three configuration registers
4. One 32 bits Multiplier
5. One 32 bits Adder


# Operation Describe:

## AXI4-Lite interface
### Write:
Performing write operation on Tap Memory or configuration register when both write address and write data are valid, write address is sampled by "awvalid" while write data is sampled by "wvalid". After sampling, "awready" and "wready" is returned for acknowledge respectively and independently. 

When write address equal to 12'h0, the AP configuration register will be written.

When write address equal to 12'h10, the register storing for data length will be written.

when write address equal to 12'h14, the register storing for the number of taps will be written.

when write address equal to 12'h40, the first entry of tap memory will be written.

when write address equal to 12'h44, the second entry of tap memory will be written and so on.


### Read
Performing read operation on Tap Memory or configuration register when "arrvalid" asserted, the information will read from address "araddr". For address 12'h10, 12'h10, 12'h14, the corresponding register is read instead. “arready” is returned for acknowledge if address sampled successfully. 

After data obtained from memory, "arvalid" and corresponding data is ready at the interface. “rready” is asserted indicating the data is exported.


### Illegal operation
All write and read operations to tap memory by AXI4 interface are treated as illegal operation. For writing operation, nothing will be written to memory but still giving out the write response signal like "awready" and "wready". For read operation, a fixed value 32'hffff_ffff is returned.

All write and to configuration register by AXI4 interface are treated as illegal operation and nothing will be written but still giving out the write response signal like "awready" and "wready"


## AXI4 - Stream interface
Performing write operation on Data memory which acts as shift register by streaming. Valid stream input comes with asserted “ss_tvalid”, “ss_tready” will be asserted if the stream input is sampled. Bubble with deasserted "ss_tvalid" is allowed between the streaming input. the last stream data come with "ss_tlast".

## Memory access
Memory write and read behaviour shown as below:
![image](https://hackmd.io/_uploads/HkMEsuznyl.png)

Data inside Tap memory will be configurated before the computation starts and will not be changed during the computation, instead, Tap memory is keep being read.

The stream input always write to the lowest index of Data memory and keep shifting from lower index to higher index in each cycle during the computation.

The default value inside of data inside Data memory is assumed as 0 and no legacy data is used, in other words, after computation finished and returned to idle, all data inside Data memory is assumed to be illegal and treated as 0 in next computation.

A FSM is introduced to control the read and write operation of both memory to prevent conflict.

![image](https://hackmd.io/_uploads/Hk7g2tG2Jx.png)

## Computation
Assumed the current stream input has not been written into data memory and the shifting has not start.
```
stream_output = tap[0]*stram_input + tap[1]*data[0] + tap[2]*data[1] + .... +  tap[10]*data[9]
```

The computation sequence shown as below
![image](https://hackmd.io/_uploads/H1PoyYznye.png)

Memory read and write operate alternately starting from the highest index. 

Multiplication and adding operate at different cycle. The stream input is handled in the end, so the computation can start before receiving a valid stream input while it can only be finished after receiving the stream input.

## Configuration register

There are there defined configuration registers, the first one is data length register which is configurated before computation start. The second one is taps number register which is also configurated before computation starts.

The third one is AP configuration register.

Bit0 of AP configuration register is named as AP_start, the computation start when it is programmed as "1" and reset it when engine is not idle.

Bit1 of AP configuration register is named as AP_done, it is programmed as "1" when the last stream output data is transferred. It will be reset when there is a read on this register.

bit2 of AP configuration register is named as AP_idle, it is reset to "1" under reset, and set to "0" when the first stream input is sampled. After the last stream output data is transferred, it will set to "1".


## Latency & Throughput 
After receiving the stream input, the engine needs 23 cycles to generate stream output, including the input cycle and output cycle.

let throughput = number of output/ a period of time = 1/23 output per cycle

## Simulation Waveform
### Coefficient program, and read back
![image](https://hackmd.io/_uploads/r1NP0KGhkl.png)

### Data-in stream-in
![image](https://hackmd.io/_uploads/H122CYz2yx.png)

### Data-out stream-out 
![image](https://hackmd.io/_uploads/rkSgkqM2ke.png)

### RAM access control
![image](https://hackmd.io/_uploads/BJM7-cfn1e.png)

### FSM operation
![image](https://hackmd.io/_uploads/B1mJW5M2kg.png)

