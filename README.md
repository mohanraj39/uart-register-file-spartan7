8-Bit UART-Controlled Register File on Spartan-7 FPGA
Overview:-
This project implements a UART-controlled 8-bit register file on a Spartan-7 (Boolean FPGA board). The design allows a user to write data to a specified address or read data back via UART,with the current address and data displayed in hexadecimal on dual 7-segment displays.

The system supports 256 addresses (00–FF), each storing:
	- An 8-bit data value
        - The original case (uppercase/lowercase) used while entering hexadecimal characters via UART

Key Features:
        - UART command interface (9600 baud)
        - 256-entry register memory (8-bit data + case metadata)
        - Read (R / r) and Write (W / w) commands
        - Case-aware hexadecimal storage and readback
        - Real-time address & data display on 7-segment LEDs
        - Visual LED blink indication on successful write operation

UART Command Format:
 Write Operation
       W <ADDR><DATA>
   Example
       W 30 FF
→ Writes 0xFF to address 0x30

 Read Operation
       R / r <ADDR>
   Example
       R 30
 UART response:
       D FF
→ Hexadecimal letters (A–F / a–f) are stored and returned in the same case used during write.

FPGA Display Behavior:
       - Left 7-segment display → Address (hex)
       - Right 7-segment display → Data (hex)
       - Display updates automatically on read/write operations
       - LED blinks briefly after a successful write

Architecture Summary
Top Module
	UART RX/TX FSM for command parsing
        256 × 10-bit register array
        [7:0] → data
        [9:8] → case flags
        Read/write control logic
        Display interface

Submodules
	uart_rx.v — UART receiver (9600 baud, 100 MHz clock)
	uart_tx.v — UART transmitter
	seven_seg.v — Time-multiplexed dual 7-segment display driver

I/O Signals
Inputs
	clk — 100 MHz system clock
	UART_rxd — UART receive line

Outputs
	UART_txd — UART transmit line
	D0_AN, D0_SEG — Address display
	D1_AN, D1_SEG — Data display
	led — Write activity indicator

Tools & Hardware
	- FPGA: Spartan-7 (Boolean FPGA board)
	- HDL: Verilog
	- Synthesis & Implementation: Xilinx Vivado
	- Serial Terminal: Tera Term
	- UART Baud Rate: 9600
	- Clock Frequency: 100 MHz

What This Project Demonstrates
	- Register file design
	- UART-based control interface
	- Finite State Machine (FSM) design
	- ASCII ↔ Hex conversion
	- FPGA pin constraint handling	
	- Real hardware verification (not simulation-only)

Possible Extensions
	- Multi-byte read/write support
	- Register protection / valid address range
	- Block RAM (BRAM) implementation
	- Simple instruction decoder (mini-SoC style)

Author
	Mohan
	Electronics & Communication Engineering
	Focused on FPGA, RTL design, and VLSI fundamentals
