`default_nettype none
`timescale 1ns / 1ps

module testbench;

  reg [7:0] datin, datin_s, cntrlin, cntrlin_s;
  reg ck, rs;
  wire [7:0] datut, datut_s, cntrlout, cntrlout_s, cntrloe, cntrloe_s;
  wire ssn, sclk, ser_out, ser_in;

  initial begin
    $display($time,"                 di ci do co ce");
    $monitor($time," THE ANSWER IS = %h %h %h %h %h", datin, cntrlin, datut, cntrlout, cntrloe);

    ck = 1'b0; rs = 1'b1;
    datin = 8'b01000000; // configure master ssn as output
    datin_s = 0; // configure slave ssn as input
    cntrlin = 0; cntrlin_s = 0;
    #10 rs = 1'b0;
    #30 rs = 1'b1;
    #5 cntrlin[1] = 1; cntrlin_s[1] = 1; // for initializing data out
    #5 cntrlin[1] = 0; cntrlin_s[1] = 0; // for initializing data out
    #50 datin = 8'h53;
    #20 cntrlin[0] = 1;
    #20 cntrlin[0] = 0;
    #150 cntrlin_s[1] = 1;
    #20 cntrlin_s[1] = 0;
    #50 datin_s = 8'h92;
    #20 cntrlin_s[0] = 1; cntrlin[0] = 1;
    #20 cntrlin_s[0] = 0; cntrlin[0] = 0;
    #150 cntrlin[1] = 1;
    #20 cntrlin[1] = 0;
    #300 $finish;
  end 

`ifdef DUMP_VCD
  initial begin
    $dumpfile("spi.vcd");
    $dumpvars(0, testbench);
  end 
`endif

  always
    #10 ck = ~ck;

  assign ssn = cntrlout[6];
  assign sclk = cntrlout[5];
  assign ser_out = cntrlout[7];
  assign ser_in = cntrlout_s[7];
//  assign cntrlin_s[6] = ssn;
//  assign cntrlin_s[2] = ser_out;
//  assign cntrlin[2] = ser_in;

  always @(*) begin
    cntrlin_s[6] = ssn;
    cntrlin_s[2] = ser_out;
    cntrlin[2] = ser_in;
  end

  tt_um_spi spi_master (
`ifdef USE_POWER_PINS
      .VPWR(1'b1),
      .VGND(1'b0),
`endif
    .ui_in(datin),    // Dedicated inputs
    .uo_out(datut),   // Dedicated outputs
    .uio_in(cntrlin),   // IOs: Input path
    .uio_out(cntrlout),  // IOs: Output path
    .uio_oe(cntrloe),   // IOs: Enable path (active high: 0=input, 1=output)
    .ena(1'b1),      // always 1 when the design is powered, so you can ignore it
    .clk(ck),      // clock
    .rst_n(rs)     // reset_n - low to reset
);
  tt_um_spi spi_slave (
`ifdef USE_POWER_PINS
      .VPWR(1'b1),
      .VGND(1'b0),
`endif
    .ui_in(datin_s),    // Dedicated inputs
    .uo_out(datut_s),   // Dedicated outputs
    .uio_in(cntrlin_s),   // IOs: Input path
    .uio_out(cntrlout_s),  // IOs: Output path
    .uio_oe(cntrloe_s),   // IOs: Enable path (active high: 0=input, 1=output)
    .ena(1'b1),      // always 1 when the design is powered, so you can ignore it
    .clk(sclk),      // clock
    .rst_n(rs)     // reset_n - low to reset
);
endmodule
