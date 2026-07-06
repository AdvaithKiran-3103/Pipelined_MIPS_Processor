# Pipelined MIPS Processor with Branch Prediction

This project implements a 16-bit 5-stage pipelined MIPS processor in SystemVerilog. The processor includes data hazard handling using forwarding and stalling, control hazard recovery using pipeline flush, and a bimodal branch predictor to reduce branch and jump penalties.

The design was verified using instruction-level testbenches and benchmark programs such as Linear Search, Fibonacci Sequence, and Bubble Sort.

---

## Project Overview

The objective of this project is to design and verify a 5-stage pipelined MIPS processor with hazard handling and branch prediction.

### Pipeline Stages

The processor follows the classic 5-stage pipeline:

1. Instruction Fetch  
2. Instruction Decode  
3. Execute  
4. Memory Access  
5. Write Back  

---

## Key Design Features

- 16-bit MIPS-like instruction format
- 5-stage pipelined datapath: IF, ID, EX, MEM, WB
- Separate instruction and data memories
- Register file with 8 general-purpose registers
- ALU support for arithmetic, logical, comparison, and shift operations
- Data hazard resolution using forwarding
- Load-use hazard detection using stall and bubble insertion
- Control hazard handling using pipeline flush and PC redirection
- Bimodal branch predictor for reducing control hazard penalty
- Benchmark-driven performance evaluation with and without branch prediction

---

## Supported Instruction Set

| Instruction Type | Instructions |
|---|---|
| R-type | ADD, SUB, AND, SLT, SRL |
| I-type | ADDI, LOAD, STORE, BEQ |
| J-type | JUMP |

### Instruction Formats

#### R-type

```text
[15:12] opcode
[11:9]  Ra
[8:6]   Rb
[5:3]   Rc
[2:0]   func
