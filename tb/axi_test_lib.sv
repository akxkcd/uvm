class base_test extends uvm_test; // {{{
 axi_env env;
 `uvm_component_utils(base_test)

 function new(string name, uvm_component parent);
   super.new(name, parent);
 endfunction : new 

 virtual function void build_phase(uvm_phase phase); 
   super.build_phase(phase);
   //env = new("env", this);
   env = axi_env::type_id::create("env", this);
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
//     set_type_override_by_type(axi_packet_input::get_type(), short_svc_packet::get_type());

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
                            axi_exhaustive_seq::type_id::get());
//     set_type_override_by_type(axi_packet_input::get_type(), short_svc_packet::get_type());
    super.build_phase(phase);
  endfunction : build_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase 

endclass : exhaustive_seq_test // }}} 
