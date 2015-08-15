class axi_env extends uvm_env; // {{{

  axi_agent agent;

  `uvm_component_utils(axi_env)

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //agent = new("agent", this);
    agent = axi_agent::type_id::create("agent", this);
  endfunction : build_phase

  virtual function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Info from env"), UVM_LOW)
  endfunction : start_of_simulation_phase

endclass : axi_env // }}}

