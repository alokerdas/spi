`default_nettype none
`timescale 1ns / 1ps

module testbench;

  reg [7:0] datin, cntrlin;
  reg ck, rs;
  wire [7:0] datut, cntrlout, cntrloe;

  initial begin
    $display($time,"                 di ci do co ce");
    $monitor($time," THE ANSWER IS = %h %h %h %h %h", datin, cntrlin, datut, cntrlout, cntrloe);

    ck = 1'b0; rs = 1'b1;
    datin = 0; cntrlin = 0;
    #5 rs = 1'b0;
    #30 rs = 1'b1;
    #50 datin = 8'h53;
    #5 cntrlin[0] = 1;
    #30 cntrlin[0] = 0;
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

  tt_um_spi spi0 (
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
endmodule
