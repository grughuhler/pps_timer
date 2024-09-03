/* Copyright 2024 Grug Huhler.  License SPDX BSD-2-Clause. */

module top
  (
   input wire  clk_in, /* The 27 MHz input clock */
   input wire  reset_button,
   input wire  button2,        /* Select from 4 accum_incr values */
   input wire  pps_in,         /* Gets timestamped.  Not used yet. */
   output wire ts63,           /* Prevents timestamp from being optimized out */
   output wire [1:0] leds,     /* Shows which accum_incr value used */
   output wire pps_pulse_out   /* Signal to monitor with scope */
   );

   /* clk_pps is 120 MHz, Fcount is 100 MHz */
   parameter TIME_INCR_VAL = 10;
   parameter PPS_COUNT_VAL = 'd100_000; /* count to 100,100 gives 1 KHz pps_pulse_out */
   parameter A_INCR_NOMINAL_VAL = 32'hd5555555; /* Yields Fcount = 100 MHz is 120 MHz */
   /* Edit these */
   parameter A_INCR_1_00000_VAL = 32'hd553b1ea;
   parameter A_INCR_1_00001_VAL = 32'hd5543db8;
   parameter A_INCR_1_00002_VAL = 32'hd554c987;

   wire        clk_pps;
   wire        button2_pulse;
   wire        reset_pps_n;
   wire [1:0]  a_incr_sel;

   assign leds = ~a_incr_sel;

   /* Create the clock used for the pps timer */
   Gowin_rPLL_PPS_20K rpll_pps
     (
      .clkout(clk_pps), /* 120 MHz */
      .clkin(clk_in)
      );

   reset_control reset_control0
     (
      .clk(clk_pps),
      .reset_in(reset_button),
      .reset_n(reset_pps_n)
      );

    rising_edge_finder button2_finder
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
