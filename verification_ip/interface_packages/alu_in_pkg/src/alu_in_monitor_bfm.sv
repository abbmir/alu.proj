//----------------------------------------------------------------------
// Created with uvmf_gen version 2022.3
//----------------------------------------------------------------------
// pragma uvmf custom header begin
// pragma uvmf custom header end
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//     
// DESCRIPTION: This interface performs the alu_in signal monitoring.
//      It is accessed by the uvm alu_in monitor through a virtual
//      interface handle in the alu_in configuration.  It monitors the
//      signals passed in through the port connection named bus of
//      type alu_in_if.
//
//     Input signals from the alu_in_if are assigned to an internal input
//     signal with a _i suffix.  The _i signal should be used for sampling.
//
//     The input signal connections are as follows:
//       bus.signal -> signal_i 
//
//      Interface functions and tasks used by UVM components:
//             monitor(inout TRANS_T txn);
//                   This task receives the transaction, txn, from the
//                   UVM monitor and then populates variables in txn
//                   from values observed on bus activity.  This task
//                   blocks until an operation on the alu_in bus is complete.
//
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//
import uvmf_base_pkg_hdl::*;
import alu_in_pkg_hdl::*;
import alu_in_pkg::*;


interface alu_in_monitor_bfm #(
  int ALU_IN_OP_WIDTH = 8
  )

  ( alu_in_if  bus );

`ifndef XRTL
// This code is to aid in debugging parameter mismatches between the BFM and its corresponding agent.
// Enable this debug by setting UVM_VERBOSITY to UVM_DEBUG
// Setting UVM_VERBOSITY to UVM_DEBUG causes all BFM's and all agents to display their parameter settings.
// All of the messages from this feature have a UVM messaging id value of "CFG"
// The transcript or run.log can be parsed to ensure BFM parameter settings match its corresponding agents parameter settings.
import uvm_pkg::*;
`include "uvm_macros.svh"
initial begin : bfm_vs_agent_parameter_debug
  `uvm_info("CFG", 
      $psprintf("The BFM at '%m' has the following parameters: ALU_IN_OP_WIDTH=%x ", ALU_IN_OP_WIDTH),
      UVM_DEBUG)
end
`endif


 alu_in_transaction #(
                      ALU_IN_OP_WIDTH
                      )
 
                      monitored_trans;
 

  // Config value to determine if this is an initiator or a responder 
  uvmf_initiator_responder_t initiator_responder;
  // Custom configuration variables.  
  // These are set using the configure function which is called during the UVM connect_phase

  tri clk_i;
  tri rst_i;
  tri  alu_rst_i;
  tri  ready_i;
  tri  valid_i;
  tri [2:0] op_i;
  tri [ALU_IN_OP_WIDTH-1:0] a_i;
  tri [ALU_IN_OP_WIDTH-1:0] b_i;
  assign clk_i = bus.clk;
  assign rst_i = bus.rst;
  assign alu_rst_i = bus.alu_rst;
  assign ready_i = bus.ready;
  assign valid_i = bus.valid;
  assign op_i = bus.op;
  assign a_i = bus.a;
  assign b_i = bus.b;

  // Proxy handle to UVM monitor
  alu_in_pkg::alu_in_monitor #(
    .ALU_IN_OP_WIDTH(ALU_IN_OP_WIDTH)
    )
 proxy;

  // pragma uvmf custom interface_item_additional begin
  // pragma uvmf custom interface_item_additional end
  
  //******************************************************************                         
  task wait_for_reset(); 
    @(posedge clk_i) ;                                                                    
    do_wait_for_reset();                                                                   
  endtask                                                                                   

  // ****************************************************************************              
  task do_wait_for_reset(); 
  // pragma uvmf custom reset_condition begin
    wait ( rst_i === 1 ) ;                                                              
    @(posedge clk_i) ;                                                                    
  // pragma uvmf custom reset_condition end                                                                
  endtask    

  //******************************************************************                         
 
  task wait_for_num_clocks(input int unsigned count); 
    @(posedge clk_i);  
                                                                   
    repeat (count-1) @(posedge clk_i);                                                    
  endtask      

  //******************************************************************                         
  event go;                                                                                 
  function void start_monitoring();  
    -> go;
  endfunction                                                                               
  
  // ****************************************************************************              
  initial begin                                                                             
    @go;                                                                                   
    forever begin                                                                        
      @(posedge clk_i);  
      monitored_trans = new("monitored_trans");
      do_monitor( );
                                                                 
 
      proxy.notify_transaction( monitored_trans ); 
 
    end                                                                                    
  end                                                                                       

  //******************************************************************
  // The configure() function is used to pass agent configuration
  // variables to the monitor BFM.  It is called by the monitor within
  // the agent at the beginning of the simulation.  It may be called 
  // during the simulation if agent configuration variables are updated
  // and the monitor BFM needs to be aware of the new configuration 
  // variables.
  //
    function void configure(alu_in_configuration 
                         #(
                         ALU_IN_OP_WIDTH
                         )
 
                         alu_in_configuration_arg
                         );  
    initiator_responder = alu_in_configuration_arg.initiator_responder;
  // pragma uvmf custom configure begin
  // pragma uvmf custom configure end
  endfunction   


  // ****************************************************************************  
  task do_monitor();
    //
    // Available struct members:
    //     //    monitored_trans.op
    //     //    monitored_trans.a
    //     //    monitored_trans.b
    //     //
    // Reference code;
    //    How to wait for signal value
    //      while (control_signal === 1'b1) @(posedge clk_i);
    //    
    //    How to assign a transaction variable, named xyz, from a signal.   
    //    All available input signals listed.
    //      monitored_trans.xyz = alu_rst_i;  //     
    //      monitored_trans.xyz = ready_i;  //     
    //      monitored_trans.xyz = valid_i;  //     
    //      monitored_trans.xyz = op_i;  //    [2:0] 
    //      monitored_trans.xyz = a_i;  //    [ALU_IN_OP_WIDTH-1:0] 
    //      monitored_trans.xyz = b_i;  //    [ALU_IN_OP_WIDTH-1:0] 
    // pragma uvmf custom do_monitor begin
    // UVMF_CHANGE_ME : Implement protocol monitoring.  The commented reference code 
    // below are examples of how to capture signal values and assign them to 
    // structure members.  All available input signals are listed.  The 'while' 
    // code example shows how to wait for a synchronous flow control signal.  This
    // task should return when a complete transfer has been observed.  Once this task is
    // exited with captured values, it is then called again to wait for and observe 
    // the next transfer. One clock cycle is consumed between calls to do_monitor.
    monitored_trans.start_time = $time;
      // Hold here until signal event happens to capture bus values
      while (valid_i == 1'b0 && alu_rst_i == 1'b1) begin
        @(posedge clk_i);
      end
      monitored_trans.op = alu_in_op_t'(op_i);
      monitored_trans.a  = a_i;
      monitored_trans.b  = b_i;

      if (alu_rst_i == 1'b0) begin
        while (alu_rst_i == 1'b0) begin
          @(posedge clk_i);
          monitored_trans.op  = rst_op;
        end
      end
    monitored_trans.end_time = $time;
    // pragma uvmf custom do_monitor end
  endtask         
  
 
endinterface

// pragma uvmf custom external begin
// pragma uvmf custom external end

