# 8-Bit UART-Controlled Register File on Spartan-7 FPGA

## Overview
This project implements a UART-controlled 8-bit register file on a Spartan-7 FPGA (Boolean Board). The design allows a user to write data to a specified address or read data back via UART, with the current address and data displayed in hexadecimal on dual 7-segment displays.

The system supports 256 addresses (00–FF), each storing:
- An 8-bit data value
- 2-bit case metadata to preserve the original uppercase/lowercase format of hexadecimal characters entered via UART

## Key Features
- UART command interface (9600 baud, 8N1)
- 256-entry register file (8-bit data + 2-bit case metadata)
- Read (R / r) and Write (W / w) commands
- Case-aware hexadecimal storage and readback
- Real-time address and data display on 7-segment LEDs
- Visual LED blink indication on successful write operation
- Verified on real FPGA hardware (not simulation-only)

## UART Command Format

### Write Operation
W <ADDR><DATA>

Example:
W 30 FF
→ Writes 0xFF to address 0x30

### Read Operation
R <ADDR>

Example:
R 30

UART Response:
D FF
→ Hexadecimal letters (A–F / a–f) are stored and returned in the same case used during the write operation

## FPGA Display Behavior
- Left 7-segment display → Address (hex)
- Right 7-segment display → Data (hex)
- Display updates automatically on read/write operations
- LED blinks briefly after a successful write

## Architecture Summary

### Top Module
- UART RX/TX FSM for command parsing
- 256 × 10-bit register array
  - [7:0] → Data
  - [9:8] → Case flags
- Read/write control logic
- Display interface logic

### Submodules
- uart_rx.v — UART receiver (9600 baud, 100 MHz clock)
- uart_tx.v — UART transmitter
- seven_seg.v — Time-multiplexed dual 7-segment display driver

## I/O Signals

### Inputs
- clk — 100 MHz system clock
- UART_rxd — UART receive line

### Outputs
- UART_txd — UART transmit line
- D0_AN, D0_SEG — Address display
- D1_AN, D1_SEG — Data display
- led — Write activity indicator

## Tools & Hardware
- FPGA: Spartan-7 (Boolean Board)
- HDL: Verilog
- Synthesis & Implementation: Xilinx Vivado
- Serial Terminal: Tera Term
- UART Baud Rate: 9600
- Clock Frequency: 100 MHz

## What This Project Demonstrates
- Register file design
- UART-based control interface
- Finite State Machine (FSM) design
- ASCII ↔ hexadecimal conversion
- FPGA pin constraint handling
- End-to-end RTL-to-hardware verification

## Possible Extensions
- Multi-byte read/write support
- Register protection and address validation
- Block RAM (BRAM) implementation
- Simple instruction decoder (mini-SoC style)

## Author
Mohanraj N
Electronics & Communication Engineering  
Focused on FPGA, RTL design, and VLSI fundamentals 
