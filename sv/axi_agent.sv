class axi_agent extends uvm_agent; // {{{

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  axi_driver     driver;
  axi_monitor    monitor;
  axi_sequencer  sequencer;

  `uvm_component_utils_begin(axi_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON) 
  `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    monitor = axi_monitor::type_id::create("monitor", this);
    if (is_active == UVM_ACTIVE) begin
      sequencer = axi_sequencer::type_id::create("sequencer", this);
      driver    = axi_driver::type_id::create("driver", this);
    end
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    if (is_active == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction : connect_phase
  
  virtual function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Info from agent"), UVM_LOW)
  endfunction : start_of_simulation_phase

endclass : axi_agent // }}}

