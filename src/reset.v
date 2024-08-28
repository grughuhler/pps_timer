/* Copyright 2024 Grug Huhler.  License SPDX BSD-2-Clause. */

module reset_control
(
 input wire  clk,
 input wire  reset_in,
 output wire reset_n
);

   reg [5:0] reset_count = 0;

   // Hold reset_n active until a count completes
   assign reset_n = &reset_count;

   always @(posedge clk)
     if (reset_in)
       reset_count <= 'b0;
     else
       reset_count <= reset_count + !reset_n;

endmodule
