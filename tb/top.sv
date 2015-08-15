//top module (tests)
//
module top ();

  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"
  import axi_pkg::*;
  // include the yapp svh file
  //`include "yapp.svh"
  `include "axi_test_lib.sv"

  // define an environment handle
  // create an environment instance
  // run the test
  //yapp_env env;
  
  //initial begin
  //  env = new("env", null);
  //end
  
// clock, reset are generated here for this DUT
  bit reset;
  bit clock; 
  wire [`IPRC_BUS_WIDTH-1:0]		axi_iprc_in_bus;		// INPUT TO RTL
  wire [179:0]				axi_cmic_write_data_bus;	// INPUT TO RTL
  wire [`SVM_IN_BUS_RANGE]		axi_in_bus;		// INPUT TO RTL

  wire [`IPRC_BUS_WIDTH-1:0]		axi_iprc_out_bus;		// OUTPUT
  wire [179:0]				axi_cmic_read_data_bus;	// OUTPUT
  wire                                 axi_cmic_read_data_bus_valid;      // OUTPUT
  wire [`SER_STATUS_BUS_RANGE]         axi_ser_status_bus;       //OUTPUT
  wire [`SVM_OUT_BUS_RANGE]		axi_out_bus;	// OUTPUT

  // YAPP Interface to the DUT
  axi_if in0 (clock,				// INPUT TO RTL
                    reset,				// INPUT
                    chip_reset_done,		// 
  axi_iprc_in_bus,		// INPUT TO RTL
  axi_cmic_write_data_bus,	// INPUT TO RTL
  axi_in_bus,		// INPUT TO RTL

  axi_iprc_out_bus,		// OUTPUT
  axi_cmic_read_data_bus,	// OUTPUT
  axi_cmic_read_data_bus_valid,      // OUTPUT
  axi_ser_status_bus,       //OUTPUT
  axi_out_bus		// OUTPUT
  );


  initial begin
  // code required for second part of lab02
  //uvm_config_wrapper::set(null, "env.agent.sequencer.run_phase",
  //                        "default_sequence",
  //                        yapp_5_packets::type_id::get());
    uvm_config_db#(virtual axi_if)::set(
                   null,
                   "*.agent.*",
                   "vif",
                   in0);
    
    run_test();
  end

  initial begin
    $timeformat(-9, 0, " ns", 8);
    reset <= 1'b0;
    clock <= 1'b1;
    //in0.in_suspend <= 1'b0;
    @(negedge clock)
      #1 reset <= 1'b0;
    @(negedge clock)
      #1 reset <= 1'b1;
  end
  
   initial // Waveform dump {{{
      begin
      $vcdpluson;
      $vcdplustraceon;
   end // }}}

  //Generate Clock
  always
    #10 clock = ~clock;


endmodule : top
