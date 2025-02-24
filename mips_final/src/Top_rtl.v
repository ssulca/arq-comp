`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
// Create Date:
// Design Name:
// Module Name: top_instancia
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// posibles ISUES https://www.xilinx.com/support/answers/51331.html
//////////////////////////////////////////////////////////////////////////////////

///  SER0090
//`include "/home/ssulca/arq-comp/mips_final/include/include.v"  //Comentar
`include "/home/sergio/arq-comp/mips_final/include/include.v"  //Comentar

///  IOTINCHO
//`include "/home/tincho/Documentos/ADC/arq-comp/mips_final/include/include.v" //Comentar
//`include "/home/martin/Documentos/arq-comp/mips_final/include/include.v" //Comentar


module Top_rtl#
  (
   parameter NB_BITS = 32
   )
   (
    output [2:0] o_led,
    output       out_tx_uart,
    //input 	    i_btnC,
    input        in_rx_uart,
    input        clk100,
    input [1:0]  i_sw
    );

   localparam GPIO_HALT_PIN = 0;

   wire [NB_BITS-1:0] gpio_i_data_tri_i;
   wire [NB_BITS-1:0] gpio_o_data_tri_o;
   wire               i_rst;
   wire               sys_clock;
   wire               clk50;
   wire               uart_rtl_rxd;
   wire               uart_rtl_txd;

   wire               halt;
   wire               halt_or_spi;
   //assign  i_rst           = i_sw;
   //assign  sys_clock       = i_clk;
   //assign  uart_rtl_rxd    = uart_txd_in;
   //assign  uart_rxd_out    = uart_rtl_txd;
   //assign  gpio_i_data_tri_i   = {{28{1'b0}}, i_sw[4:1]};
   assign  o_led[1]   = gpio_o_data_tri_o[29];//SCLK conectamos lo primeros byts
   assign  o_led[2]   = gpio_o_data_tri_o[30];//STEP conectamos lo primeros byts
   assign  o_led[0]   = gpio_o_data_tri_o[31];//CONTINUE conectamos lo primeros byts

   assign halt_or_spi = (|gpio_o_data_tri_o[28:25])? gpio_i_data_tri_i[GPIO_HALT_PIN]:halt;
   ///////////////////////////////////////////
   //////////////    MicroBlaze   ////////////
   ///////////////////////////////////////////
   design_1 #()
   u_micro
     (
      .clock50        (clk50),             // Clock aplicacion
      .gpio_rtl_tri_o (gpio_o_data_tri_o), // GPIO OUTPUT
      .gpio_rtl_tri_i ({gpio_i_data_tri_i[NB_BITS-1:1], halt_or_spi}), // GPIO INPUT
      .reset          (i_sw[0]),           // Hard Reset
      .sys_clock      (clk100),            // Clock de FPGA
      //.o_lock_clock // Senal Lock Clock
      .usb_uart_rxd   (in_rx_uart),        // UART RX
      .usb_uart_txd   (out_tx_uart)        // UART TX
      );

   ///////////////////////////////////////////
   //////////////    MIPS         ////////////
   ///////////////////////////////////////////
   Mips #()
   inst_Mips
     (
      .o_MISO      (gpio_i_data_tri_i),
      .o_halt      (halt),//esta negado para que la salida sea activa por alto
      //.o_operation (o_operation),
      // //.o_function  (o_function),
      .i_clk       (clk50),
      .i_rst       (i_sw[1]),
      .i_continue  (gpio_o_data_tri_o[31]),
      .i_valid     (gpio_o_data_tri_o[30]),    // por flanco ascendente
      .i_MOSI      ({7'd0, gpio_o_data_tri_o[24:0]}),
      .i_SCLK      (gpio_o_data_tri_o[29]),
      .i_SPI_cs    (gpio_o_data_tri_o[28:25])
      );

endmodule // Top_rtl
