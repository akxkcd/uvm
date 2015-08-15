class axi_driver extends uvm_driver #(axi_packet_input); // {{{
  
  // Declare this property to count packets sent
  int num_sent;
  virtual interface axi_if vif;
  
  `uvm_component_utils(axi_driver)

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
    `uvm_info(get_type_name(), $sformatf("Info from driver"), UVM_LOW)
  endfunction : start_of_simulation_phase // }}}

  virtual function void build_phase(uvm_phase phase); // {{{
    assert(
           uvm_config_db#(virtual axi_if)::get(
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
      vif.axi_in_bus  <=  'h1;
`ifdef TEMP_SWITCH_OFF
      vif.in_data_vld       <= 1'b0;
`endif
      disable send_to_dut;
    end
  endtask : reset_signals // }}}

  task send_to_dut(axi_packet_input packet); // {{{
  `uvm_info(get_type_name(), $sformatf("Packet is \n%0s", packet.sprint()), UVM_LOW)
    // Wait for packet delay
    repeat(packet.packet_delay)
      @(negedge vif.clk);
    
    // Begin Transaction recording
    void'(this.begin_tr(packet, "Input_axi_packet_input"));
    
    vif.axi_in_bus  <= packet.in_bus;
    
    repeat(1)
      @(negedge vif.clk);
    // End transaction recording
    this.end_tr(packet);

  endtask : send_to_dut // }}}

  function void report_phase(uvm_phase phase); // {{{
    `uvm_info(get_type_name(), $sformatf("Report: YAPP TX driver sent %0d packets", num_sent), UVM_LOW)
  endfunction : report_phase // }}}

endclass : axi_driver // }}}

