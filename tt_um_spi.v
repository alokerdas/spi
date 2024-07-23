/*
 * tt_um_spi.v
 *
 * Simple SPI protocol
 *
 * Author: Aloke Kumar Das <aloke.das@ieee.org>
 */

module tt_um_spi (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  reg rst_n_i;
  reg [7:0] msconfig;

  assign uio_oe = msconfig; // Lower nibble all input, Upper all output
  assign uio_out[4:0] = msconfig[4:0]; // uio_out unused bits

//  always_latch begin // for yosys
  always @(*) begin
    if (~rst_n) begin
      msconfig <= ui_in;
    end
  end

  always @(posedge clk or negedge rst_n)
    if (~rst_n) rst_n_i <= 1'b0;
    else rst_n_i <= 1'b1;

  spi spi0 (
    .reset(~rst_n_i),
    .clock_in(clk),
    .load(uio_in[0]),
    .unload(uio_in[1]),
    .miso(uio_in[2]),
    .ssn_in(uio_in[6]),
    .ssn_out(uio_out[6]),
    .sclk(uio_out[5]),
    .mosi(uio_out[7]),
    .datain(ui_in),
    .dataout(uo_out)
);
  // avoid linter warning about unused pins:
  wire _unused_pins = ena;

endmodule  // tt_um_spi
