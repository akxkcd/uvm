#!/usr/local/bin/perl

use strict;
use warnings;
use Cwd;

use Getopt::Long;
# To run: perl create_uvm_env.pl -p design_ex -u design_ex -i design_ex: Generates master only testbench files. 
# perl create_uvm_env.pl -p design_ex -u design_ex -i design_ex -s slave : Generates slave agent files
my $packet    = "axi_packet";
my $uvc       = "axi";
my $interface = "axi";
my $slave     = "noslave";
my $length = 24;
my $verbose;
my $print_only = 0;
  GetOptions (
#              "depth=i" => \$depth,    # numeric
              "packet=s"   => \$packet,      # string
              "uvc=s"   => \$uvc,      # string
              "interface=s"   => \$interface,      # string
              "slave=s"   => \$slave,      # string
              "verbose"  => \$verbose)   # flag
  or die("Error in command line arguments\n");

  create_env($uvc, $packet, $slave);

sub create_env {
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $slave  = shift(@_);
  print "uvc will be created for $uvc\n";
  print "packet is $packet \n";
  print "slave is $slave \n";
  if (!-d "sv") {
    mkdir("sv");
  }
  if (!-d "tb") {
    mkdir("tb");
  }
  
  create_uvc($uvc, $packet, $slave, "sv");
  
  create_tb_files($uvc, $packet, $slave, "tb");
}

sub create_uvc { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $slave  = shift(@_);
  my $uvc_dir= shift(@_);
  my $slave_uvc;
  print "Creating $uvc_dir include file with packet: $packet, uvc: $uvc\n";
  create_uvc_include($uvc, $packet, $uvc_dir);
  create_uvc_monitor($uvc, $packet, $uvc_dir);
  create_uvc_sequencer($uvc, $packet, $uvc_dir);
  create_uvc_seqs($uvc, $packet, $uvc_dir);
  create_uvc_driver($uvc, $packet, $uvc_dir);
  create_uvc_agent($uvc, $packet, $uvc_dir);
  create_uvc_env($uvc, $packet, $uvc_dir);
  create_uvc_pkg($uvc, $packet, $uvc_dir);
  if ($slave ne "noslave") {
    $slave_uvc = $uvc."_".$slave;
    create_uvc_include($slave_uvc, $packet, $uvc_dir);
    create_uvc_monitor($slave_uvc, $packet, $uvc_dir);
    create_uvc_sequencer($slave_uvc, $packet, $uvc_dir);
    create_uvc_seqs($slave_uvc, $packet, $uvc_dir);
    create_slave_driver($slave_uvc, $packet, $uvc_dir);
    create_uvc_agent($slave_uvc, $packet, $uvc_dir);
    create_uvc_env($slave_uvc, $packet, $uvc_dir);
    create_uvc_pkg($slave_uvc, $packet, $uvc_dir);
  }
} # }}}

sub create_tb_files { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $slave  = shift(@_);
  my $uvc_dir= shift(@_);
  create_makefile($uvc, $packet, $uvc_dir);
  create_vlist($uvc, $packet, $uvc_dir);
  create_tb($uvc, $packet, $uvc_dir);
  create_test_lib($uvc, $packet, $slave, $uvc_dir);
  create_top($uvc, $packet, $slave, $uvc_dir);
} # }}}

sub create_uvc_include { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "$uvc_dir/"."$uvc"."_include.svh";

  open($fh, ">$fileName");
  
    print $fh <<EOF
`ifndef ${UVC}_INCLUDE_SVH
`define ${UVC}_INCLUDE_SVH

typedef uvm_config_db#(virtual ${interface}_if) ${uvc}_vif_config;

import uvm_pkg::*;

`include "uvm_macros.svh"
`include "${packet}_input.svh"
`include "${uvc}_monitor.sv"
`include "${uvc}_sequencer.sv"
`include "${uvc}_seqs.sv"
`include "${uvc}_driver.sv"
`include "${uvc}_agent.sv"
`include "${uvc}_env.sv"

`endif // ${UVC}_INCLUDE_SVH

EOF

} # }}}

sub create_uvc_monitor { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "$uvc_dir/"."$uvc"."_monitor.sv";

  open($fh, ">$fileName");

    print $fh <<EOF
class ${uvc}_monitor extends uvm_monitor; // {{{
  
  `uvm_component_utils(${uvc}_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new 

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(), \$sformatf("Info from monitor"), UVM_LOW)
  endtask : run_phase

  virtual function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), \$sformatf("Info from monitor"), UVM_LOW)
  endfunction : start_of_simulation_phase

endclass : ${uvc}_monitor // }}}
EOF

} # }}}

sub create_uvc_sequencer { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "$uvc_dir/"."$uvc"."_sequencer.sv";

  open($fh, ">$fileName");

    print $fh <<EOF

class ${uvc}_sequencer extends uvm_sequencer #(${packet}_input); // {{{
	`uvm_sequencer_utils(${uvc}_sequencer)
	function new (string name, uvm_component parent);
		super.new(name, parent);
		`uvm_update_sequence_lib_and_item(${packet}_input)
	endfunction : new
endclass : ${uvc}_sequencer // }}}

EOF
} # }}}

sub create_uvc_seqs { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "$uvc_dir/"."$uvc"."_seqs.sv";

  open($fh, ">$fileName");

    print $fh <<EOF
//------------------------------------------------------------------------------
//
// SEQUENCE: base ${uvc} sequence - base sequence with objections from which 
// all sequences can be derived
//
//------------------------------------------------------------------------------
class ${uvc}_base_seq extends uvm_sequence #(${packet}_input); // {{{
  
  // Required macro for sequences automation
  `uvm_object_utils(${uvc}_base_seq)

  // Constructor
  function new(string name="${uvc}_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    starting_phase.raise_objection(this, get_type_name());
    `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
  endtask : pre_body

  task post_body();
    starting_phase.drop_objection(this, get_type_name());
    `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
  endtask : post_body

endclass : ${uvc}_base_seq // }}}

class ${uvc}_1_seq extends ${uvc}_base_seq; // {{{
  
  // Required macro for sequences automation
  `uvm_object_utils(${uvc}_1_seq)

  // Constructor
  function new(string name="${uvc}_1_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing ${uvc}_1_seq sequence", UVM_LOW)
    `uvm_do_with(req, {addr == 1;})    
  endtask : body

endclass : ${uvc}_1_seq // }}}

class ${uvc}_exhaustive_seq extends ${uvc}_base_seq; // {{{
  
  ${uvc}_1_seq y_1_seq;
  // Required macro for sequences automation
  `uvm_object_utils(${uvc}_exhaustive_seq)

  // Constructor
  function new(string name="${uvc}_exhaustive_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing ${uvc}_exhaustive_seq sequence", UVM_LOW)
    `uvm_do(y_1_seq)
  endtask : body

endclass : ${uvc}_exhaustive_seq // }}}

EOF
} # }}}

sub create_uvc_driver { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "$uvc_dir/"."$uvc"."_driver.sv";

  open($fh, ">$fileName");

    print $fh <<EOF
class ${uvc}_driver extends uvm_driver #(${packet}_input); // {{{
  
  // Declare this property to count packets sent
  int num_sent;
  virtual interface ${interface}_if vif;
  
  `uvm_component_utils(${uvc}_driver)

  function new(string name, uvm_component parent); // {{{
    super.new(name, parent); 
  endfunction // }}}

  task run_phase(uvm_phase phase); // {{{
    fork
      get_and_drive();
      reset_signals();
    join
  endtask : run_phase // }}}
  
  task get_and_drive(); // {{{
    @(posedge vif.rst_l);
    `uvm_info(get_type_name(), "Reset dropped", UVM_MEDIUM)
    forever begin
       //Add your code here to:
       //Get new item from the sequencer
       //Drive the item
       //Communicate item done to the sequencer
      seq_item_port.get_next_item(req);
      send_to_dut(req);
      seq_item_port.item_done();
    end
  endtask : get_and_drive // }}}
  
  virtual function void start_of_simulation_phase(uvm_phase phase); // {{{
    `uvm_info(get_type_name(), \$sformatf("Info from driver"), UVM_LOW)
  endfunction : start_of_simulation_phase // }}}

  virtual function void build_phase(uvm_phase phase); // {{{
    assert(
           uvm_config_db#(virtual ${interface}_if)::get(
                                  this,
                                  "",
                                  "vif",
                                  vif) 
          );
  endfunction : build_phase // }}}
 
  task reset_signals(); // {{{
    forever begin
      @(negedge vif.rst_l);
       `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
      vif.${uvc}_in_bus  <=  'h1;
`ifdef TEMP_SWITCH_OFF
      vif.in_data_vld       <= 1'b0;
`endif
      disable send_to_dut;
    end
  endtask : reset_signals // }}}

  task send_to_dut(${packet}_input packet); // {{{
  `uvm_info(get_type_name(), \$sformatf("Packet is \\n%0s", packet.sprint()), UVM_LOW)
    // Wait for packet delay
    repeat(packet.packet_delay)
      @(negedge vif.clk);
    
    // Begin Transaction recording
    void'(this.begin_tr(packet, "Input_${packet}_input"));
    
    vif.${uvc}_in_bus  <= packet.in_bus;
    
    repeat(1)
      @(negedge vif.clk);
    // End transaction recording
    this.end_tr(packet);

  endtask : send_to_dut // }}}

  function void report_phase(uvm_phase phase); // {{{
    `uvm_info(get_type_name(), \$sformatf("Report: YAPP TX driver sent %0d packets", num_sent), UVM_LOW)
  endfunction : report_phase // }}}

endclass : ${uvc}_driver // }}}

EOF
} # }}}

sub create_slave_driver { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "$uvc_dir/"."$uvc"."_driver.sv";

  open($fh, ">$fileName");

    print $fh <<EOF
class ${uvc}_driver extends uvm_driver #(${packet}_input); // {{{
  
  // Declare this property to count packets sent
  int num_sent;
  virtual interface ${interface}_if vif;
  
  `uvm_component_utils(${uvc}_driver)

  function new(string name, uvm_component parent); // {{{
    super.new(name, parent); 
  endfunction // }}}

  task run_phase(uvm_phase phase); // {{{
    fork
      get_and_drive();
      reset_signals();
    join
  endtask : run_phase // }}}
  
  task get_and_drive(); // {{{
    @(posedge vif.rst_l);
    `uvm_info(get_type_name(), "Reset dropped", UVM_MEDIUM)
    forever begin
       //Add your code here to:
       //Get new item from the sequencer
       //Drive the item
       //Communicate item done to the sequencer
       @(posedge vif.clk);
       send_response();
    end
  endtask : get_and_drive // }}}
  
  virtual function void start_of_simulation_phase(uvm_phase phase); // {{{
    `uvm_info(get_type_name(), \$sformatf("Info from driver"), UVM_LOW)
  endfunction : start_of_simulation_phase // }}}

  virtual function void build_phase(uvm_phase phase); // {{{
    assert(
           uvm_config_db#(virtual ${interface}_if)::get(
                                  this,
                                  "",
                                  "vif",
                                  vif) 
          );
  endfunction : build_phase // }}}
 
  task reset_signals(); // {{{
    forever begin
      @(negedge vif.rst_l);
       `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
      vif.${interface}_in_bus  <=  'h1;
`ifdef TEMP_SWITCH_OFF
      vif.in_data_vld       <= 1'b0;
`endif
    end
  endtask : reset_signals // }}}

  task send_response(); // {{{
    design_ex_input temp_packet;
    temp_packet = new();
    temp_packet.in_bus = vif.design_ex_in_bus;
    `uvm_info(get_type_name(), \$sformatf("Packet is %0s", temp_packet.sprint()), UVM_LOW);

  endtask : send_response // }}}

  function void report_phase(uvm_phase phase); // {{{
    `uvm_info(get_type_name(), \$sformatf("Report: YAPP TX driver sent %0d packets", num_sent), UVM_LOW)
  endfunction : report_phase // }}}

endclass : ${uvc}_driver // }}}

EOF
} # }}}

sub create_uvc_agent { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "$uvc_dir/"."$uvc"."_agent.sv";

  open($fh, ">$fileName");

    print $fh <<EOF
class ${uvc}_agent extends uvm_agent; // {{{

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  ${uvc}_driver     driver;
  ${uvc}_monitor    monitor;
  ${uvc}_sequencer  sequencer;

  `uvm_component_utils_begin(${uvc}_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON) 
  `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    monitor = ${uvc}_monitor::type_id::create("monitor", this);
    if (is_active == UVM_ACTIVE) begin
      sequencer = ${uvc}_sequencer::type_id::create("sequencer", this);
      driver    = ${uvc}_driver::type_id::create("driver", this);
    end
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    if (is_active == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction : connect_phase
  
  virtual function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), \$sformatf("Info from agent"), UVM_LOW)
  endfunction : start_of_simulation_phase

endclass : ${uvc}_agent // }}}

EOF
} # }}}

sub create_uvc_env { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "$uvc_dir/"."$uvc"."_env.sv";

  open($fh, ">$fileName");

    print $fh <<EOF
class ${uvc}_env extends uvm_env; // {{{

  ${uvc}_agent agent;

  `uvm_component_utils(${uvc}_env)

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //agent = new("agent", this);
    agent = ${uvc}_agent::type_id::create("agent", this);
  endfunction : build_phase

  virtual function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), \$sformatf("Info from env"), UVM_LOW)
  endfunction : start_of_simulation_phase

endclass : ${uvc}_env // }}}

EOF
} # }}}

sub create_uvc_pkg { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "$uvc_dir/"."$uvc"."_pkg.sv";

  open($fh, ">$fileName");

    print $fh <<EOF
package ${uvc}_pkg;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  `include "${uvc}_include.svh"

endpackage
EOF
} # }}}

sub create_uvc_unused { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "$uvc_dir/"."$uvc"."_unused.sv";

  open($fh, ">$fileName");

    print $fh <<EOF

EOF
} # }}}

sub create_makefile { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "${uvc_dir}/Makefile";

  open($fh, ">$fileName");

    print $fh <<EOF
DIR := ../sv
all: comp run

clean:
	rm -rf simv* csrc *.log *vpd vc_hdrs.h ucli.key

comp:
	vcs -sverilog -debug_pp +dump_on +dump_top  +librescan +v2k -timescale=1ns/1ns -ntb_opts uvm-1.1 +incdir+\$(DIR) -f common.vlist  -l comp.log

run:
	simv  +UVM_NO_RELNOTES   +UVM_TESTNAME=exhaustive_seq_test -l run.log +dump_on +dump_top 

base:	
	simv  +UVM_NO_RELNOTES   +UVM_TESTNAME=base_test -l run.log 
EOF
} # }}}

sub create_vlist { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "${uvc_dir}/common.vlist";

  open($fh, ">$fileName");

    print $fh <<EOF
+incdir+../sv
../sv/${interface}_if.sv
../sv/${uvc}_pkg.sv
top.sv
EOF
} # }}}

sub create_tb { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "$uvc_dir/"."$uvc"."_tb.sv";

  open($fh, ">$fileName");

    print $fh <<EOF
class ${uvc}_tb extends uvm_component; // {{{

  `uvm_component_utils(${uvc}_tb)

  function new(string name, uvm_component parent); // {{{
    super.new(name, parent);
  endfunction : new // }}}

  virtual function void build_phase(uvm_phase phase); // {{{
    set_config_int("*", "recording_detail", 1);
    super.build_phase(phase);
  endfunction : build_phase // }}}

endclass : ${uvc}_tb // }}}

EOF
} # }}}

sub create_test_lib { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $slave  = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "$uvc_dir/"."$uvc"."_test_lib.sv";

  open($fh, ">$fileName");

  print $fh "class base_test extends uvm_test; // {{{\n";

  if ($slave ne "noslave") {
    print $fh " ${uvc}_${slave}_env slave_env;\n";
  }
  
  print $fh <<EOF
 ${uvc}_env env;
 `uvm_component_utils(base_test)

 function new(string name, uvm_component parent);
   super.new(name, parent);
 endfunction : new 

 virtual function void build_phase(uvm_phase phase); 
   super.build_phase(phase);
   //env = new("env", this);
   env = ${uvc}_env::type_id::create("env", this);
EOF
;
  if ($slave ne "noslave") {
    print $fh "   slave_env = ${uvc}_${slave}_env::type_id::create(\"slave_env\", this);\n";
  }
#  print $fh " ${uvc}_env env;\n";
  
  print $fh <<EOF
  endfunction : build_phase

  function void check_phase(uvm_phase phase);
    check_config_usage();
  endfunction
 
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase 
endclass : base_test // }}}

class short_packet_test extends base_test; // {{{

  `uvm_component_utils(short_packet_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new 

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
//     set_type_override_by_type(${packet}_input::get_type(), short_svc_packet::get_type());

  endfunction

endclass : short_packet_test // }}}

class set_config_test extends base_test; // {{{

  `uvm_component_utils(set_config_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new 
 
  virtual function void build_phase(uvm_phase phase);
    set_config_int("env.agent", "is_active", UVM_PASSIVE);
    super.build_phase(phase);

  endfunction : build_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase 
endclass : set_config_test // }}}

class exhaustive_seq_test extends base_test; // {{{

  `uvm_component_utils(exhaustive_seq_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new 
 
  virtual function void build_phase(uvm_phase phase);
    uvm_config_wrapper::set(this, "env.agent.sequencer.run_phase",
                            "default_sequence",
                            ${uvc}_exhaustive_seq::type_id::get());
//     set_type_override_by_type(${packet}_input::get_type(), short_svc_packet::get_type());
    super.build_phase(phase);
  endfunction : build_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase 

endclass : exhaustive_seq_test // }}} 
EOF
} # }}}

sub create_tb_unused { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "$uvc_dir/"."$uvc"."_tb_unused.sv";

  open($fh, ">$fileName");

    print $fh <<EOF

EOF
} # }}}

sub create_top { # {{{
  my $uvc    = shift(@_);
  my $packet = shift(@_);
  my $slave  = shift(@_);
  my $uvc_dir= shift(@_);
  my $UVC    = uc($uvc);
  my $fh;
  my $fileName = "${uvc_dir}/top.sv";

  open($fh, ">$fileName");

    print $fh <<EOF
//top module (tests)
//
module top ();

  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"
  import ${uvc}_pkg::*;
EOF
;

  if ($slave ne "noslave") {
    print $fh "  import ${uvc}_${slave}_pkg::*;\n";
  }
    print $fh <<EOF
  // include the yapp svh file
  //`include "yapp.svh"
  `include "${uvc}_test_lib.sv"

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
  wire [`IPRC_BUS_WIDTH-1:0]		${uvc}_iprc_in_bus;		// INPUT TO RTL
  wire [179:0]				${uvc}_cmic_write_data_bus;	// INPUT TO RTL
  wire [`SVM_IN_BUS_RANGE]		${uvc}_in_bus;		// INPUT TO RTL

  wire [`IPRC_BUS_WIDTH-1:0]		${uvc}_iprc_out_bus;		// OUTPUT
  wire [179:0]				${uvc}_cmic_read_data_bus;	// OUTPUT
  wire                                 ${uvc}_cmic_read_data_bus_valid;      // OUTPUT
  wire [`SER_STATUS_BUS_RANGE]         ${uvc}_ser_status_bus;       //OUTPUT
  wire [`SVM_OUT_BUS_RANGE]		${uvc}_out_bus;	// OUTPUT

  // YAPP Interface to the DUT
  ${interface}_if in0 (clock,				// INPUT TO RTL
                    reset,				// INPUT
                    chip_reset_done,		// 
  ${uvc}_iprc_in_bus,		// INPUT TO RTL
  ${uvc}_cmic_write_data_bus,	// INPUT TO RTL
  ${uvc}_in_bus,		// INPUT TO RTL

  ${uvc}_iprc_out_bus,		// OUTPUT
  ${uvc}_cmic_read_data_bus,	// OUTPUT
  ${uvc}_cmic_read_data_bus_valid,      // OUTPUT
  ${uvc}_ser_status_bus,       //OUTPUT
  ${uvc}_out_bus		// OUTPUT
  );


  initial begin
  // code required for second part of lab02
  //uvm_config_wrapper::set(null, "env.agent.sequencer.run_phase",
  //                        "default_sequence",
  //                        yapp_5_packets::type_id::get());
    uvm_config_db#(virtual ${interface}_if)::set(
                   null,
                   "*.agent.*",
                   "vif",
                   in0);
    
    run_test();
  end

  initial begin
    \$timeformat(-9, 0, " ns", 8);
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
      \$vcdpluson;
      \$vcdplustraceon;
   end // }}}

  //Generate Clock
  always
    #10 clock = ~clock;


endmodule : top
EOF
} # }}}

if ($verbose) {
  print "print_only=1 -> Prints the directories found\n";
  print "The script deletes core*, ctb, and executes psh make clean in\n";
  print "directories containing test.sv\n";
}
