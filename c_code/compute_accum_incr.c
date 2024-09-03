/* Copyright 2024 Grug Huhler.  License SPDX BSD-2-Clause */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void usage(void)
{
  fprintf(stderr, "%s",
          "To use with picorv32:\n"
          "  Enter command iu and ix to stop PPS printing and updating.\n"
          "  Enter ip 186a0 to select 1 KHz pps_out frequency\n"
          "  Enter ia d5555555 and measure pps_out frequency on scope\n"
          "  Run with program with that frequency as the argument, e.g.\n"
          "     ./compute_accum_incr 1.00002\n"
          "  It will print ia commands to get frequencies 1.00000, 1.00001,\n"
          "  1.00002, and 1.00003 KHz.\n");
  exit(EXIT_FAILURE);
}

int main(int argc, char **argv)
{
  double f_d5555555;
  uint32_t a_incr_1_00000;
  uint32_t a_incr_1_00001;
  uint32_t a_incr_1_00002;
  uint32_t a_incr_1_00003;

  if (argc != 2) usage();

  f_d5555555 =  atof(argv[1]);

  a_incr_1_00000 = 0xd5555555/f_d5555555 + 0.5;
  a_incr_1_00001 = a_incr_1_00000*1.00001 + 0.5;
  a_incr_1_00002 = a_incr_1_00000*1.00002 + 0.5;
  a_incr_1_00003 = a_incr_1_00000*1.00003 + 0.5;

  printf("A_INCR_1_00000_VAL for 1.00000 KHz: ia %x\n", a_incr_1_00000);
  printf("A_INCR_1_00001_VAL for 1.00001 KHz: ia %x\n", a_incr_1_00001);
  printf("A_INCR_1_00002_VAL for 1.00002 KHz: ia %x\n", a_incr_1_00002);
  printf("                   For 1.00003 KHz: ia %x\n", a_incr_1_00003);

  return 0;
}
