
`timescale 1ns/1ps

`include "define.vh"

module distance(
    // output
    output bit [`NUM_BIT-1:0]    dist_out,
    output bit [1:0]    label_out,
    output bit [7:0]    index_out,

    // input
    input  bit [`NUM_BIT-1:0]    dist_in,
    input  bit [1:0]    label_in,
    input  bit [7:0]    index_in,

    input  bit [7:0]    x,  // one attribute of training sample
    input  bit [7:0]    y   // one attribute of testing sample
);

    
    bit [`NUM_BIT-1:0]  x_ext, y_ext;

    assign  x_ext = {{(`NUM_BIT-7){x[7]}}, x[6:0]};
    assign  y_ext = {{(`NUM_BIT-7){y[7]}}, y[6:0]};


    // --------------------------------------------------------------
    // Implement your design from here







endmodule
