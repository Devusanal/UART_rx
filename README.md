# UART Receiver on Digilent Arty A7-100T

---

## Table of Contents

* Overview / Introduction
* Features
* Design Description
* Project Implementation
* Prerequisites
* Getting Started / Setup Instructions
* Usage Instructions
* Directory Structure
* Technical Details


---

## Overview / Introduction

This project implements a **UART Receiver (RX)** in Verilog on the Digilent Arty A7-100T FPGA board. The design receives serial data from a PC via the onboard USB-UART interface at **9600 baud**, converts it into 8-bit parallel data, and displays the received byte using onboard LEDs.

The lower 4 bits of the received byte are mapped to the standard green LEDs, while the upper 4 bits are mapped to the blue components of the RGB LEDs.

The design uses a finite state machine (FSM) approach and mid-bit sampling to ensure reliable UART reception.

Development and implementation are carried out using Vivado.

---

## Features

* UART RX at 9600 baud
* FSM-based receiver (Idle, Start, Data, Stop, Cleanup)
* Mid-bit sampling for noise immunity
* Active-low reset
* 8-bit data reception
* Data Valid pulse (`rx_dv`)
* Real-time LED visualization of received bytes
* Tested on Arty A7-100T @ 100 MHz clock

---

## Design Description

### UART Receiver (`uart_rx.v`)

The UART receiver performs the following steps:

1. Waits for start bit (logic 0)
2. Samples in the middle of the start bit
3. Receives 8 data bits (LSB first)
4. Waits for stop bit
5. Asserts `rx_dv` for one clock cycle
6. Outputs received byte on `rx_byte`

Key parameters:

```
CLK_FREQ  = 100000000
BAUD_RATE = 9600
```

FSM States:

* STATE_IDLE
* STATE_START
* STATE_DATA
* STATE_STOP
* STATE_CLEANUP

---

### Top Module (`top.v`)

* Instantiates `uart_rx`
* Stores received byte when `rx_dv` goes high
* Maps:

  * `display_data[3:0]` → Green LEDs
  * `display_data[7:4]` → Blue RGB LEDs

---

## Project Implementation

### FPGA-Based UART Reception

Workflow:

1. PC sends serial data through USB-UART.
2. FPGA receives serial stream on `uart_txd_in`.
3. `uart_rx` converts serial data into 8-bit parallel format.
4. `rx_dv` indicates valid data.
5. Top module captures data.
6. LEDs display received byte.

This provides a simple real-time visualization of UART communication.

---

## Prerequisites

### Software

* Vivado Design Suite
* Serial Terminal ( TeraTerm )

### Hardware

* Digilent Arty A7-100T FPGA board

---

## Getting Started / Setup Instructions


### Vivado Setup

1. Create a new RTL project.
2. Add:

   * `uart_rx.v`
   * `top.v`
   * `constraints.xdc`
3. Set `top` as top module.
4. Run:

   * Synthesis
   * Implementation
   * Generate Bitstream
5. Program FPGA.

---

## Usage Instructions

1. Connect Arty A7 via USB.
2. Open serial terminal:

| Parameter | Value |
| --------- | ----- |
| Baud Rate | 9600  |
| Data Bits | 8     |
| Parity    | None  |
| Stop Bits | 1     |

3. Send ASCII characters.
4. Observe LED changes.

### Example

Sending:

```
A (0x41 → 01000001)
```

Results:

* Green LEDs → `0001`
* Blue LEDs → `0100`

---

## Directory Structure

```
.
├── uart_rx.v        # UART receiver module
├── top.v           # Top-level module
├── constraints.xdc # Arty A7 pin constraints
└── README.md
```

---

## Technical Details

### Clock

* 100 MHz system clock
* Bit timing derived using:

```
CLKS_PER_BIT = CLK_FREQ / BAUD_RATE
```

---

### UART Sampling

Start bit is verified at mid-point to reject glitches.
Each data bit is sampled after one full bit period.

---

### LED Mapping

* Lower nibble → Green LEDs
* Upper nibble → RGB Blue LEDs

This allows visualization of full 8-bit data.

---




