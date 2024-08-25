# Simple Video Game Processor for VGA

## Project Overview

This project is part of the COE758 Digital Systems Engineering course and involves the design and implementation of a Simple Video Game Processor (SVGP) on an FPGA. The project focuses on interfacing an FPGA with a VGA display to create a basic video game. The game field is displayed in green with white borders, and it includes dynamic elements such as a yellow "ball" and two players, one in blue and the other in red. The project demonstrates real-time signal generation and FPGA-based video processing.

## Objectives

- Understand the functionality of video-output subsystems and VGA standards.
- Gain practical experience in FPGA to I/O device interfacing.
- Develop VHDL coding skills for real-time applications using Xilinx ISE CAD tools.
- Implement a simple video game processor on the Xilinx Spartan-3E FPGA.

## Specifications

- **Static Video Frame:** Green game field with white borders.
- **Dynamic Elements:** 
  - Yellow "ball" that moves across the field, bouncing off borders and players.
  - Two players in blue and red, controlled by switches to move up and down.
- **Game Behavior:**
  - The ball changes direction by 90 degrees upon hitting a border or player.
  - When the ball passes through a gate on either side, it turns red and reappears in the center after disappearing.
  
## VGA Display Specifications

- **Resolution:** 640x480
- **Refresh Rate:** 60Hz
- **Pixel Clock:** 25MHz
- **Input Clock:** 50MHz (system clock)

## Tools and Platform

- **FPGA:** Xilinx Spartan-3E
- **CAD Tool:** Xilinx ISE
- **Programming Language:** VHDL

## Symbol Diagram
![Symbol](https://github.com/user-attachments/assets/8cd056d3-9f8d-431f-93e7-3ff004c0cff4)

**Figure 1**: VGA Symbol Diagram


## Block Diagram

![Block](https://github.com/user-attachments/assets/bd1819cd-9e56-4b9a-b263-0fdb588b76e8)

**Figure 2**: Complete block diagram of the game


## State Diagrams

![state1](https://github.com/user-attachments/assets/c53b187d-036a-4f59-b778-9b627c641dba)

**Figure 3**: DAC_clk FSM

![fig4](https://github.com/user-attachments/assets/34e6e126-b508-44c3-a82e-270de8705137)

**Figure 4**: Hsync FSM

![fig5](https://github.com/user-attachments/assets/2bebcf30-6cc9-4da0-8584-9b88af76a9b8)

**Figure 5**: Vsync FSM

## How to Run

1. Open the project in Xilinx ISE.
2. Synthesize the VHDL code and generate the programming file.
3. Upload the programming file to the Spartan-3E FPGA.
4. Connect the VGA monitor to the FPGA board.
5. Use the switches on the board to control the players and observe the gameplay on the VGA monitor.

## Challenges and Learnings

- Implementing real-time signal processing and ensuring accurate VGA display output.
- Developing efficient collision detection algorithms for the ball and players.
- Troubleshooting unexpected behavior in the ball's movement, especially during inverse hits.

## Conclusion

This project provided hands-on experience in digital system engineering, particularly in video processing and FPGA design. The integration of theoretical knowledge with practical implementation was a key learning outcome.
