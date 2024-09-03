/* Copyright 2024 Grug Huhler.  License SPDX BSD-2-Clause. */

module pps_timer
  #(
    parameter TIME_INCR_VAL = 0,
    PPS_COUNT_VAL = 0,
    A_INCR_NOMINAL_VAL = 0,
    A_INCR_1_00000_VAL = 0,
    A_INCR_1_00001_VAL = 0,
    A_INCR_1_00002_VAL = 0
    )
   (
    input wire       clk_pps,
    input wire       reset_pps_n,
    inout wire       button2_pulse,
    input wire       pps_in,
    output wire      ts63,
    output reg [1:0] a_incr_sel,
    output reg       pps_pulse_out
    );

   wire              pps_in_sync;
   reg [63:0]        time_ctr;
   reg [63:0]        timestamp;
   reg [7:0]         time_incr;
   reg [31:0]        accum_ctr;
   wire [31:0]       accum_incr;
   reg [31:0]        a_incr_nominal;
   reg [31:0]        a_incr_1_00000;
   reg [31:0]        a_incr_1_00001;
   reg [31:0]        a_incr_1_00002;
   reg [31:0]        pps_count;
   reg [31:0]        pps_ctr;
   reg               carry;

   /* ts63 (and pps_in, time_ctr and timestamp) don't accomplish anything in
    * this demo.  Signals pps_in and ts63 are kept to prevent these parts
    * of the design from being swept in optimization.  It keeps the design
    * complete.
    */

   assign ts63 = timestamp[63];

   /* convert pps_in to a single cycle pulse in pps_in_sync */

   rising_edge_finder pps_in_finder
     (
      .clk(clk_pps),
      .reset_n(reset_pps_n),
      .sig_in(pps_in),
      .pulse(pps_in_sync)
      );

   /* This always block implements the time_ctr, accum_ctr, and
    * pps_ctr counters Reg accum increments by accum_incr every clock_pps
    * cycle.  This generates carry.  When carry is high, pps_ctr decrments,
    * and time_ctr is incremented by time_incr.
    */

   always @(posedge clk_pps or negedge reset_pps_n)
     if (!reset_pps_n) begin
        timestamp <= 1'b0;
        time_ctr <= 1'b0;
        time_incr <= TIME_INCR_VAL;
        accum_ctr <= 1'b0;
        pps_count <= PPS_COUNT_VAL; /* 1 KHz assuming 100 MHz Fcount */
        pps_ctr <= 1'b1;
        carry <= 1'b0;
        pps_pulse_out <= 1'b0;
     end else begin

        {carry,accum_ctr} <= accum_ctr + accum_incr;

        if (pps_in_sync) begin
           /* capture timestamp on rising edge of the pps input */
           timestamp <= time_ctr;
        end

        if (carry) begin
           time_ctr <= time_ctr + time_incr;
           if (pps_ctr < pps_count)
             pps_ctr <= pps_ctr + 32'b1;
           else
             pps_ctr <= 32'b1;
           /* Set the PPS output pulse with duty cycle ~25% */        
           if (pps_ctr < (pps_count >> 2))
             pps_pulse_out <= 1'b1;
           else
             pps_pulse_out <= 1'b0;
        end

     end

   /* Cause button2_edge to select value of accum_incr */
   always @(posedge clk_pps or negedge reset_pps_n)
     if (!reset_pps_n) begin
        a_incr_sel <= 2'b00;
        a_incr_nominal <= A_INCR_NOMINAL_VAL;
        a_incr_1_00000 <= A_INCR_1_00000_VAL;
        a_incr_1_00001 <= A_INCR_1_00001_VAL;
        a_incr_1_00002 <= A_INCR_1_00002_VAL;
     end else begin
        if (button2_pulse) begin
           if (a_incr_sel == 2'b11)
             a_incr_sel <= 2'b00;
           else
             a_incr_sel <= a_incr_sel + 2'b01;
        end
     end

   assign accum_incr = a_incr_sel == 2'b00 ? a_incr_nominal :
                       a_incr_sel == 2'b01 ? a_incr_1_00000 :
                       a_incr_sel == 2'b10 ? a_incr_1_00001 : a_incr_1_00002;
                       
endmodule
