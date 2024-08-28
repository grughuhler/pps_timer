/* Copyright 2024 Grug Huhler.  License SPDX BSD-2-Clause. */

module top
  (
   input wire  clk_in, /* The 27 MHz input clock */
   input wire  reset_button,
   input wire  button2,
   input wire  pps_in,
   output wire ts63,
   output wire [1:0] leds,
   output wire pps_pulse_out
   );

   /* clk_pps is 60 MHz, Fcount is 50 MHz, but 120 MHz is possible */
   parameter TIME_INCR_VAL = 20;
   parameter PPS_COUNT_VAL = 50000;
   parameter A_INCR_NOMINAL_VAL = 32'hd5555555;
   parameter A_INCR_1_00000_VAL = 32'hd555b733;
   parameter A_INCR_1_00001_VAL = 32'hd5564303;
   parameter A_INCR_1_00002_VAL = 32'hd556ced2;

   wire        clk_pps;
   wire        button2_pulse;
   wire        reset_pps_n;
   wire [1:0]  a_incr_sel;

   assign leds = ~a_incr_sel;

   /* Create the clock used for the pps timer */
   Gowin_rPLL_PPS_9K rpll_pps
     (
      .clkout(clk_pps), /* 60 MHz */
      .clkin(clk_in)
      );

   reset_control reset_control0
     (
      .clk(clk_pps),
      .reset_in(~reset_button), /* Tang 9K buttons are 0 when pressed */
      .reset_n(reset_pps_n)
      );

    /* Tang Nano 9K button goes low when pressed */
    falling_edge_finder button2_finder
      (
         .clk(clk_pps),
         .reset_n(reset_pps_n),
         .sig_in(button2),
         .pulse(button2_pulse)
      );

   pps_timer
     #(
       .TIME_INCR_VAL(TIME_INCR_VAL),
       .PPS_COUNT_VAL(PPS_COUNT_VAL),
       .A_INCR_NOMINAL_VAL(A_INCR_NOMINAL_VAL),
       .A_INCR_1_00000_VAL(A_INCR_1_00000_VAL),
       .A_INCR_1_00001_VAL(A_INCR_1_00001_VAL),
       .A_INCR_1_00002_VAL(A_INCR_1_00002_VAL)
       )
   pps_timer0
     (
      .clk_pps(clk_pps),
      .reset_pps_n(reset_pps_n),
      .button2_pulse(button2_pulse),
      .pps_in(pps_in),
      .ts63(ts63),
      .a_incr_sel(a_incr_sel),
      .pps_pulse_out(pps_pulse_out)
      );

endmodule // top
