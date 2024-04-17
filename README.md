# 5-Stage Pipelined Processor and Assembler
This repository contains the implementation of a 5-stage pipelined processor and its corresponding assembler, designed primarily in VHDL. The design aims to mimic a real-world CPU pipeline, including components for fetching, decoding, executing, memory access, and write-back stages, along with associated hazard detection and control units.

## Instructions
First run the below commands to configure modelsim. After that, open the `Processor/Processor.mpf` file with modelsim.
```bash
$~ cd ./Processor/
$~/Processor/ python modelsim_configure.py
```
After modelsim opens you should be able to view the folder structure in the `Processor` directory duplicated in modelsim. Run the below command to ensure work library is created in the modelsim terminal
```bash
<ModelSim> vlib work
```

## Processor Design Overview
The processor architecture is built around a 5-stage pipeline, allowing for increased instruction throughput. Each stage is designed to perform specific tasks, and files corresponding to each stage are organized within their respective directories.

## Pipeline Stages
1. *Fetch*: Responsible for fetching the next instruction from memory.
2. *Decode*: Decodes the fetched instruction and prepares necessary signals and data paths for execution.
3. *Execute*: Executes the operation specified by the instruction.
4. *Memory*: Handles data memory access, including load and store instructions.
5. *Writeback*: Completes the instruction by writing results back to registers

## Processor Components
- PC (Program Counter)
- Fetch Unit
- Decode Unit (Including various register components)
- Execute Unit (Including ALU, CCR - Condition Code Register)
- Data Memory
- Writeback Unit
- Branch Handling
- Controller Unit
- Hazard Detection Unit (HDU)
- Forwarding Unit
- Stack Pointer (SP)

## Folder Structure
```
├── Processor/
│   ├── Fetch/
│   │   ├── PC.vhd  (Program Counter)
│   │   ├── Fetch.vhd
│   │   └── ...
│   ├── Decode/
│   │   ├── Decode.vhd
│   │   ├── Decode0Registers.vhd
│   │   ├── Decode1Registers.vhd
│   │   ├── Decode2Registers.vhd
│   │   ├── Decode3Registers.vhd
│   │   ├── RegisterFile.vhd
│   │   ├── ControllerUnit.vhd
│   │   └── ...
│   ├── Execute/
│   │   ├── Execute.vhd
│   │   ├── CCR.vhd  (Condition Code Register)
│   │   ├── ALU.vhd  (Arithmetic Logic Unit)
│   │   └── ...
│   ├── Memory/
│   │   ├── DataMemory.vhd
│   │   ├── SP.vhd  (Stack Pointer)
│   │   └── ...
│   ├── Writeback/
│   │   ├── Writeback.vhd
│   │   └── ...
│   ├── HazardDetection/
│   │   ├── HDU.vhd  (Hazard Detection Unit)
│   │   ├── BranchPrediction.vhd
│   │   └── ForwardingUnit.vhd
│   ├── General/
│   │   ├── Register.vhd
│   │   └── ... (rest of tiny components)
├── Assembler/
│   ├── assembler.py
│   └── example.txt
└── Diagrams/
    ├── ...
    └── ... (rest of deliverables)
```

# Assembler
Included is a Python-based assembler (`assembler.py`) that translates assembly code into machine code understood by the processor. An example assembly file (`example.txt`) is also provided to demonstrate usage.
