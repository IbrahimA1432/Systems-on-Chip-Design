# COE838 – Systems-on-Chip Design

This repository contains selected coursework, labs, and project work from COE838: Systems-on-Chip Design at Toronto Metropolitan University.

The course focused on system-on-chip design, hardware/software co-design, SystemC-based modeling, FPGA/HPS integration, custom IP design, and embedded system prototyping using FPGA development tools.

## Topics Covered

- System-on-Chip (SoC) design methodology
- Hardware/software co-design
- SystemC modeling and simulation
- FPGA/HPS integration
- Custom IP development
- Avalon-MM memory-mapped interfaces
- QSys/Platform Designer system integration
- VHDL-based hardware design
- Embedded C applications running on the HPS
- Performance and logic utilization analysis

## Tools and Platforms

- VHDL
- C
- SystemC
- Quartus-II
- QSys / Platform Designer
- ModelSim
- DE1-SoC FPGA platform
- ARM-A9 HPS
- Avalon-MM interfaces

## Repository Structure

```text
labs/
  Selected lab work involving SystemC, FPGA/HPS integration, and custom IP design.

project/
  Final SoC project involving an MD5 hardware/software co-design implementation.
```

## Notes

This repository is intended as a technical portfolio and learning archive. Course-provided handouts, lab manuals, and starter files are not included. Only my own implementation work, documentation, diagrams, and summaries are included where appropriate.

# Main Project: MD5 SoC Accelerator

This project explores hardware/software co-design for an MD5 hashing system using an FPGA/HPS SoC architecture.

The system uses FPGA hardware to accelerate MD5 computation while an embedded C application running on the HPS controls data transfer, execution, and result verification.

## Project Goals

- Design an MD5 hardware acceleration system using VHDL
- Interface FPGA hardware with HPS software through memory-mapped I/O
- Implement control and data transfer using Avalon-MM style communication
- Compare serial and parallel execution approaches
- Measure performance using total hashes, execution time, and hash rate
- Analyze FPGA logic utilization and timing performance

## System Overview

The design consists of:

- MD5 hardware engine implemented in VHDL
- Avalon-MM control and data interfaces
- HPS-based C application for software control
- Memory-mapped communication between HPS and FPGA fabric
- Simulation and verification using ModelSim
- FPGA synthesis and timing/resource analysis using Quartus-II

## Hardware/Software Interaction

The HPS application sends message data to the FPGA hardware core through memory-mapped writes. The FPGA computes the MD5 digest and returns the result through memory-mapped reads.

The 512-bit input message is transferred in 32-bit segments, and the 128-bit MD5 digest is read back in multiple 32-bit segments.

## Implementation Highlights

- VHDL hardware modules for MD5 computation and control
- Embedded C software for FPGA/HPS communication
- Preprocessor-based configuration for serial and parallel execution modes
- Correctness checking against expected digest values
- Runtime tracking of hash count, execution time, and hash rate
- FPGA resource and timing analysis

## Tools Used

- VHDL
- C
- Quartus-II
- QSys / Platform Designer
- ModelSim
- DE1-SoC platform
- ARM-A9 HPS
- Yocto Linux environment

## Results

Results are included in the form of a report as a PDF

# Lab 4 – Custom IP and Avalon-MM Interface

This lab focused on integrating custom FPGA IP into an HPS/FPGA SoC system using Avalon-MM memory-mapped interfaces.

## Objectives

- Generate and integrate custom FPGA IP
- Wrap hardware IP with control/status logic
- Create Avalon-MM slave interfaces
- Connect FPGA peripherals to the HPS through QSys/Platform Designer
- Access hardware registers from C software using memory-mapped I/O

## System Overview

The lab design used a custom multiplier IP core connected to the HPS through Avalon-MM slave interfaces. Separate control and data interfaces were used to manage input data, execution control, and result retrieval.

## Key Concepts

- Avalon-MM master/slave communication
- Memory-mapped hardware registers
- Custom VHDL IP wrappers
- FPGA/HPS bridge communication
- Embedded C control of FPGA peripherals
- Quartus and QSys system integration

## Tools Used

- VHDL
- C
- Quartus-II
- QSys / Platform Designer
- DE1-SoC FPGA platform
