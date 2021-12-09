//------------------------------------------------------------------------------
// (c) Copyright 2004-2009 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 
// -----------------------------------------------------------------------------
// Description:  This module creates a Gigabit Media Independent
//               Interface (GMII) by instantiating Input/Output buffers
//               and Input/Output flip-flops as required.
//
//               This interface is used to connect the Ethernet MAC to
//               an external Ethernet PHY via GMII connection.
//
//               The GMII receiver clocking logic is also defined here: the
//               receiver clock received from the PHY is unique and cannot be
//               shared across multiple instantiations of the core.  For the
//               receiver clock:
//
//               A PLL/MMCM is used to deskew the clock.
//------------------------------------------------------------------------------

`timescale 1 ps / 1 ps


module gmii_sync (
    // The following ports are the GMII physical interface: these will be at
    // pins on the FPGA
    output reg [7:0] gmii_txd,
    output reg       gmii_tx_en,
    output reg       gmii_tx_er,
    output           gmii_tx_clk,
    input      [7:0] gmii_rxd,
    input            gmii_rx_dv,
    input            gmii_rx_er,
    input            gmii_rx_clk,

    // The following ports are the internal GMII connections from IOB logic to
    // the TEMAC core
    input      [7:0] eth_txd,
    input            eth_tx_en,
    input            eth_tx_er,
    input            eth_tx_clk,	// 125MHz Clock
    output reg [7:0] eth_rxd,
    output reg       eth_rx_dv,
    output reg       eth_rx_er,
    output           eth_rx_clk

    );


  //----------------------------------------------------------------------------
  // internal signals
  //----------------------------------------------------------------------------


  wire            rx_clk_int;
  wire            rx_clk0;
  
  wire            clkfbout;
  wire            clkfbout_bufg;
  
  //----------------------------------------------------------------------------
  // GMII Transmitter Clock Management :
  // drive gmii_tx_clk through IOB onto GMII interface
  //----------------------------------------------------------------------------


   // Instantiate a DDR output register.  This is a good way to drive
   // GMII_TX_CLK since the clock-to-PAD delay will be the same as that
   // for data driven from IOB Ouput flip-flops eg gmii_rxd[7:0].
   // This is set to produce an inverted clock w.r.t. gmii_tx_clk_int
   // so that the rising edge is centralised within the
   // gmii_rxd[7:0] valid window.
   ODDR gmii_tx_clk_ddr_iob (
      .Q                (gmii_tx_clk),
      .C                (eth_tx_clk),
      .CE               (1'b1),
      .D1               (1'b0),
      .D2               (1'b1),
      .R                (1'b0),
      .S                (1'b0)
   );


   //---------------------------------------------------------------------------
   // GMII Transmitter Logic : drive TX signals through IOBs registers onto
   // GMII interface
   //---------------------------------------------------------------------------


   // Infer IOB Output flip-flops.
   always @(posedge eth_tx_clk)
   begin
      gmii_tx_en           <= eth_tx_en;
      gmii_tx_er           <= eth_tx_er;
      gmii_txd             <= eth_txd;
   end


   //---------------------------------------------------------------------------
   // GMII Receiver Clock Logic
   //---------------------------------------------------------------------------
  
 
/*    PLLE2_ADV #(
      .BANDWIDTH         ("OPTIMIZED"),
      .COMPENSATION      ("ZHOLD"),
      .DIVCLK_DIVIDE     (1),
      .CLKFBOUT_MULT     (9),
      .CLKFBOUT_PHASE    (0.000),
      .CLKOUT0_DIVIDE    (9),
      .CLKOUT0_PHASE     (0.000),
      .CLKOUT0_DUTY_CYCLE(0.500),
      .CLKIN1_PERIOD     (8.0),
      .REF_JITTER1       (0.010)
   ) plle2_adv_inst (
      .CLKFBOUT          (clkfbout),
      .CLKOUT0           (rx_clk0),
    // Input clock control
      .CLKFBIN           (clkfbout_bufg),
      .CLKIN1            (gmii_rx_clk),
      .CLKIN2            (1'b0),
    // Tied to always select the primary input clock
      .CLKINSEL          (1'b1),
    // Ports for dynamic reconfiguration
      .DADDR             (7'h0),
      .DCLK              (1'b0),
      .DEN               (1'b0),
      .DI                (16'd0),
      .DWE               (1'b0),
    // Other control and status signals
      .LOCKED            (),
      .PWRDWN            (1'b0),
      .RST               (1'b0)
   ); */

//   BUFG bufg_rx_clk_fb (
//      .I              (clkfbout),
//      .O              (clkfbout_bufg)
//   );
      
  // Output buffering
  //-----------------------------------

   BUFG bufg_gmii_rx_clk (
      .I              (gmii_rx_clk),
      .O              (rx_clk_int)
   );
   
   // Assign the internal clock signal to the output port
   assign eth_rx_clk = rx_clk_int;


   // Infer IOB Input flip-flops.
   always @(posedge rx_clk_int)
   begin
      eth_rx_dv <= gmii_rx_dv;
      eth_rx_er <= gmii_rx_er;
      eth_rxd   <= gmii_rxd;
   end



endmodule
