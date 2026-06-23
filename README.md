# Asynchronous_FIFO
A parameterizable ***Asynchronous FIFO(First In First Out)*** implemented in ***SystemVerilog***. Features Gray-coded pointers for safe Clock Domain Crossing (CDC), robust full/empty flag generation, and synthesizable RTL design.

## Features
- Parameterized Data_Width and Address_Width(Depth)
- Independent Write and Read Domains
- Gray-coded read/write pointer to metastability during transistion from one state to other.
- Two Flip-Flop synchronization for CDC(Clock Domain Crossing)
- Full and Empty Flag generation by write point handler block and read point handler block respectively
- Asynchronous read memory and synchronous write memory

## Project Structure
```text
.
├── async_fifo.sv
├── fifo_mem.sv
├── fifo_rptr.sv
├── fifo_sync.sv
├── fifo_wptr.sv
├── tb.sv
└── README.md
```

## Module Description
### 1. async_fifo
This is a top level module that instatiates all other modules and ties them togother
- Instantiates FIFO memory
- Connect read and write domains and synchronize them
- Generates full and empty flags.

### 2. fifo_mem
This module represents memory array of FIFO 
- Synchronous write  
- Asynchronous read 

### 3. fifo_rptr
Implementation of Read Pointer Handler 
- Gray-code, Binary conversion 
- Empty Flag 
- Read address 

### 4. fifo_wptr
Implementation of Write Pointer Handler
- Gray-code, Binary conversion 
- Full Flag 
- Write address 

### 5. fifo_sync
Two-stage flip-flop synchronizer
- Safely transfers Gray-coded pointers between different clock domains while minimizing metastability


## Clock Domain Crossing
The FIFO uses:
- Binary counters for memory addressing 
- Gray-code pointers for synchronization 
- Two-stage synchronizers for pointer transfer 
Since only one Gray-code bit changes at a time, the probability of sampling multiple changing bits simultaneously is significantly reduced 

## Paramters
DATA_WIDTH
ADDR_WIDTH


## FIFO DEPTH
DEPTH = 2^(ADDR_WIDTH)


## How It Works

### Write Operation

1. Write request arrives.
2. If FIFO is not full:
   - Data is written into memory.
   - Binary write pointer increments.
   - Gray pointer updates.
3. Gray pointer is synchronized into the read clock domain.
---

### Read Operation
1. Read request arrives.
2. If FIFO is not empty:
   - Data is read from memory.
   - Binary read pointer increments.
   - Gray pointer updates.
3. Gray pointer is synchronized into the write clock domain.

### Simulation
Example using Icarus Verilog:
```bash
iverilog -g2012 *.sv
vvp a.out
```
---

## Applications
- Clock Domain Crossing (CDC) 
- UART 
- SPI
- AXI Stream 
- Network interfaces 
- DSP pipelines
- FPGA communication 


## Author

**Pavan Kumar Mukku**

Electrical Engineering  
Indian Institute of Technology Madras
