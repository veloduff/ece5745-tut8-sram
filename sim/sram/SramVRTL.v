//========================================================================
// SRAM RTL with custom low-level interface
//========================================================================
// This is the SRAM RTL model with our own low-level interface. It
// contains an instance of either a SRAM generated by CACTI memory
// compiler or a This is the SRAM RTL model with our own low-level
// interfacegeneric SRAM RTL model (SramGenericPRTL).
//
// The interface of this module are prefixed by port0_, meaning all reads
// and writes happen through the only port. Multiported SRAMs have ports
// prefixed by port1_, port2_, etc.
//
// The following list describes each port of this module.
//
//  Port Name     Direction  Description
//  ----------------------------------------------------------------------
//  port0_val     I          port enable (1 = enabled)
//  port0_type    I          transaction type, 0 = read, 1 = write
//  port0_idx     I          index of the SRAM
//  port0_wdata   I          write data
//  port0_wben    I          write byte enable (1 = enabled)
//  port0_rdata   O          read data output
//

`ifndef SRAM_SRAM_VRTL
`define SRAM_SRAM_VRTL

`include "sram/SramGenericVRTL.v"
`include "sram/SRAM_32x256_1P.v"
`include "sram/SRAM_128x256_1P.v"

// ''' TUTORIAL TASK '''''''''''''''''''''''''''''''''''''''''''''''''''''
// Include new SRAM configuration RTL model
// '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

module sram_SramVRTL
#(
  parameter p_data_nbits  = 32,
  parameter p_num_entries = 256,

  // Local constants not meant to be set from outside the module
  parameter c_addr_nbits  = $clog2(p_num_entries),
  parameter c_data_nbytes = (p_data_nbits+7)/8 // $ceil(p_data_nbits/8)
)(
  input  logic                      clk,
  input  logic                      reset,
  input  logic                      port0_val,
  input  logic                      port0_type,
  input  logic [c_addr_nbits-1:0]   port0_idx,
  input  logic [p_data_nbits-1:0]   port0_wdata,
  output logic [p_data_nbits-1:0]   port0_rdata,
  input  logic [c_data_nbytes-1:0]  port0_wben
);

  // Short hands: we define these short hands below to make the generate
  // statements a bit more compact. Note that we tried using positional
  // arguments instead of explicit named port connections, but this
  // actually didn't work with Synopsys DC for some reason.

  logic                     v;
  logic                     t;
  logic [c_addr_nbits-1:0]  i;
  logic [p_data_nbits-1:0]  wd;
  logic [p_data_nbits-1:0]  rd;
  logic [c_data_nbytes-1:0] wben;

  assign v    = port0_val;
  assign t    = port0_type;
  assign i    = port0_idx;
  assign wd   = port0_wdata;
  assign wben = port0_wben;

  assign port0_rdata = rd;

  generate
    if      ( p_data_nbits == 32  && p_num_entries == 256 )
      SRAM_32x256_1P  sram ( .CE1(clk), .WEB1(~t), .OEB1(1'b0), .CSB1(~v), .A1(i), .I1(wd), .O1(rd), .WBM1(wben) );
    else if ( p_data_nbits == 128 && p_num_entries == 256 )
      SRAM_128x256_1P sram ( .CE1(clk), .WEB1(~t), .OEB1(1'b0), .CSB1(~v), .A1(i), .I1(wd), .O1(rd), .WBM1(wben) );

    // ''' TUTORIAL TASK '''''''''''''''''''''''''''''''''''''''''''''''''
    // Choose new SRAM configuration RTL model
    // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

    else
      sram_SramGenericVRTL#(p_data_nbits,p_num_entries) sram
      (
        .CE1  ( clk  ),
        .WEB1 ( ~t   ),
        .OEB1 ( 1'b0 ),
        .CSB1 ( ~v   ),
        .A1   ( i    ),
        .I1   ( wd   ),
        .O1   ( rd   ),
        .WBM1 ( wben )
      );

  endgenerate

endmodule

`endif /* SRAM_SRAM_VRTL */

