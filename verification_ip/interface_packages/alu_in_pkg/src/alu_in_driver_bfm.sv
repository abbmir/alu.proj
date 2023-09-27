//----------------------------------------------------------------------
// Created with uvmf_gen version 2022.3
//----------------------------------------------------------------------
// pragma uvmf custom header begin
// pragma uvmf custom header end
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//     
// DESCRIPTION: 
//    This interface performs the alu_in signal driving.  It is
//     accessed by the uvm alu_in driver through a virtual interface
//     handle in the alu_in configuration.  It drives the singals passed
//     in through the port connection named bus of type alu_in_if.
//
//     Input signals from the alu_in_if are assigned to an internal input
//     signal with a _i suffix.  The _i signal should be used for sampling.
//
//     The input signal connections are as follows:
//       bus.signal -> signal_i 
//
//     This bfm drives signals with a _o suffix.  These signals
//     are driven onto signals within alu_in_if based on INITIATOR/RESPONDER and/or
//     ARBITRATION/GRANT status.  
//
//     The output signal connections are as follows:
//        signal_o -> bus.signal
//
//                                                                                           
//      Interface functions and tasks used by UVM components:
//
//             configure:
//                   This function gets configuration attributes from the
//                   UVM driver to set any required BFM configuration
//                   variables such as 'initiator_responder'.                                       
//                                                                                           
//             initiate_and_get_response:
//                   This task is used to perform signaling activity for initiating
//                   a protocol transfer.  The task initiates the transfer, using
//                   input data from the initiator struct.  Then the task captures
//                   response data, placing the data into the response struct.
//                   The response struct is returned to the driver class.
//
//             respond_and_wait_for_next_transfer:
//                   This task is used to complete a current transfer as a responder
//                   and then wait for the initiator to start the next transfer.
//                   The task uses data in the responder struct to drive protocol
//                   signals to complete the transfer.  The task then waits for 
//                   the next transfer.  Once the next transfer begins, data from
//                   the initiator is placed into the initiator struct and sent
//                   to the responder sequence for processing to determine 
//                   what data to respond with.
//
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//
import uvmf_base_pkg_hdl::*;
import alu_in_pkg_hdl::*;
import alu_in_pkg::*;

interface alu_in_driver_bfm #(
  int ALU_IN_OP_WIDTH = 8
  )

  (alu_in_if bus);

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

  // Config value to determine if this is an initiator or a responder 
  uvmf_initiator_responder_t initiator_responder;
  // Custom configuration variables.  
  // These are set using the configure function which is called during the UVM connect_phase

  tri clk_i;
  tri rst_i;

  // Signal list (all signals are capable of being inputs and outputs for the sake
  // of supporting both INITIATOR and RESPONDER mode operation. Expectation is that 
  // directionality in the config file was from the point-of-view of the INITIATOR

  // INITIATOR mode input signals
  tri  ready_i;
  reg  ready_o = 'b0;

  // INITIATOR mode output signals
  tri  alu_rst_i;
  reg  alu_rst_o = 'b0;
  tri  valid_i;
  reg  valid_o = 'b0;
  tri [2:0] op_i;
  reg [2:0] op_o = 'b0;
  tri [ALU_IN_OP_WIDTH-1:0] a_i;
  reg [ALU_IN_OP_WIDTH-1:0] a_o = 'b0;
  tri [ALU_IN_OP_WIDTH-1:0] b_i;
  reg [ALU_IN_OP_WIDTH-1:0] b_o = 'b0;

  // Bi-directional signals
  

  assign clk_i = bus.clk;
  assign rst_i = bus.rst;

  // These are signals marked as 'input' by the config file, but the signals will be
  // driven by this BFM if put into RESPONDER mode (flipping all signal directions around)
  assign ready_i = bus.ready;
  assign bus.ready = (initiator_responder == RESPONDER) ? ready_o : 'bz;


  // These are signals marked as 'output' by the config file, but the outputs will
  // not be driven by this BFM unless placed in INITIATOR mode.
  assign bus.alu_rst = (initiator_responder == INITIATOR) ? alu_rst_o : 'bz;
  assign alu_rst_i = bus.alu_rst;
  assign bus.valid = (initiator_responder == INITIATOR) ? valid_o : 'bz;
  assign valid_i = bus.valid;
  assign bus.op = (initiator_responder == INITIATOR) ? op_o : 'bz;
  assign op_i = bus.op;
  assign bus.a = (initiator_responder == INITIATOR) ? a_o : 'bz;
  assign a_i = bus.a;
  assign bus.b = (initiator_responder == INITIATOR) ? b_o : 'bz;
  assign b_i = bus.b;

  // Proxy handle to UVM driver
  alu_in_pkg::alu_in_driver #(
    .ALU_IN_OP_WIDTH(ALU_IN_OP_WIDTH)
    )
  proxy;


  // ****************************************************************************
// pragma uvmf custom reset_condition_and_response begin
  // Always block used to return signals to reset value upon assertion of reset
  always @( negedge rst_i )
     begin
       // RESPONDER mode output signals
       ready_o <= 'b0;
       // INITIATOR mode output signals
       alu_rst_o <= 'b0;
       valid_o <= 'b0;
       op_o <= 'b0;
       a_o <= 'b0;
       b_o <= 'b0;
       // Bi-directional signals
 
     end    
// pragma uvmf custom reset_condition_and_response end

  // pragma uvmf custom interface_item_additional begin
    always@(negedge rst_i)
    begin
          alu_rst_o <= 1'b0;
          valid_o   <= 1'b0;
    end

    always@(posedge rst_i)
    begin
          alu_rst_o <= 1'b1;
    end   
  // pragma uvmf custom interface_item_additional end

  //******************************************************************
  // The configure() function is used to pass agent configuration
  // variables to the driver BFM.  It is called by the driver within
  // the agent at the beginning of the simulation.  It may be called 
  // during the simulation if agent configuration variables are updated
  // and the driver BFM needs to be aware of the new configuration 
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

// pragma uvmf custom initiate_and_get_response begin
// ****************************************************************************
// UVMF_CHANGE_ME
// This task is used by an initator.  The task first initiates a transfer then
// waits for the responder to complete the transfer.
    task initiate_and_get_response( alu_in_transaction 
                                  #(
                                  ALU_IN_OP_WIDTH
                                  )

                                  initiator_trans  
                                  );
       // 
       // Variables within the initiator_trans:
       //   alu_in_op_t op ;
       //   bit [ALU_IN_OP_WIDTH-1:0] a ;
       //   bit [ALU_IN_OP_WIDTH-1:0] b ;
       //
       // Reference code;
       //    How to wait for signal value
       //      while (control_signal == 1'b1) @(posedge clk_i);
       //    
       //    How to assign a initiator_trans variable, named xyz, from a signal.   
       //    All available initiator input and inout signals listed.
       //    Initiator input signals:
       //      initiator_trans.xyz = ready_i;  //     
       //    Initiator inout signals:
       //    How to assign a signal, named xyz, from a initiator_trans varaiable.   
       //    All available initiator output and inout signals listed.
       //    Notice the _o.  Those are storage variables that allow for procedural assignment.
       //    Initiator output signals:
       //      alu_rst_o <= initiator_trans.xyz;  //     
       //      valid_o <= initiator_trans.xyz;  //     
       //      op_o <= initiator_trans.xyz;  //    [2:0] 
       //      a_o <= initiator_trans.xyz;  //    [ALU_IN_OP_WIDTH-1:0] 
       //      b_o <= initiator_trans.xyz;  //    [ALU_IN_OP_WIDTH-1:0] 
       //    Initiator inout signals:
    // Initiate a transfer using the data received.
    @(posedge clk_i);
    $display("alu_in_driver_bfm : Inside initiate_and_get_response");
    case (initiator_trans.op)
      rst_op  : do_assert_rst(initiator_trans.op);
      default : alu_in_op(initiator_trans.op, initiator_trans.a, initiator_trans.b);
    endcase
  endtask        
  
  // ****************************************************************************
  task do_assert_rst(input alu_in_op_t op);
  $display("%d ***************   Starting Reset", $time);
     op_o <= op;
     alu_rst_o <= 1'b0;
     repeat (10) @(posedge clk_i);
     alu_rst_o <= 1'b1;
     repeat (5) @(posedge clk_i);
  $display("%d ***************   Ending Reset", $time);
  endtask
 
// ****************************************************************************
  task alu_in_op(input alu_in_op_t op,
                 input bit [ALU_IN_OP_WIDTH-1:0] a,
                 input bit [ALU_IN_OP_WIDTH-1:0] b);
      
     alu_rst_o <= 1'b1;
     while ( ready_i == 1'b0 ) @(posedge clk_i) ;
     valid_o <= 1'b1;
     op_o <= op;
     a_o <= a;
     b_o <= b;
      
     @(posedge clk_i);
     valid_o <= 1'b0;
     op_o <= {3{1'bz}};
     a_o <= {ALU_IN_OP_WIDTH{1'bz}};
     b_o <= {ALU_IN_OP_WIDTH{1'bz}};
     
   endtask 
  
// pragma uvmf custom initiate_and_get_response end

// pragma uvmf custom respond_and_wait_for_next_transfer begin
// ****************************************************************************
// The first_transfer variable is used to prevent completing a transfer in the 
// first call to this task.  For the first call to this task, there is not
// current transfer to complete.
bit first_transfer=1;

// UVMF_CHANGE_ME
// This task is used by a responder.  The task first completes the current 
// transfer in progress then waits for the initiator to start the next transfer.
  
  task respond_and_wait_for_next_transfer( alu_in_transaction 
                                         #(
                                         ALU_IN_OP_WIDTH
                                         )

                                         responder_trans  
                                         );     
  // Variables within the responder_trans:
  //   alu_in_op_t op ;
  //   bit [ALU_IN_OP_WIDTH-1:0] a ;
  //   bit [ALU_IN_OP_WIDTH-1:0] b ;
       // Reference code;
       //    How to wait for signal value
       //      while (control_signal == 1'b1) @(posedge clk_i);
       //    
       //    How to assign a responder_trans member, named xyz, from a signal.   
       //    All available responder input and inout signals listed.
       //    Responder input signals
       //      responder_trans.xyz = alu_rst_i;  //     
       //      responder_trans.xyz = valid_i;  //     
       //      responder_trans.xyz = op_i;  //    [2:0] 
       //      responder_trans.xyz = a_i;  //    [ALU_IN_OP_WIDTH-1:0] 
       //      responder_trans.xyz = b_i;  //    [ALU_IN_OP_WIDTH-1:0] 
       //    Responder inout signals
       //    How to assign a signal from a responder_trans member named xyz.   
       //    All available responder output and inout signals listed.
       //    Notice the _o.  Those are storage variables that allow for procedural assignment.
       ///   Responder output signals
       //      ready_o <= responder_trans.xyz;  //     
       //    Responder inout signals
    

  @(posedge clk_i);
  if (!first_transfer) begin
    // Perform transfer response here.   
    // Reply using data recieved in the responder_trans.
    @(posedge clk_i);
    // Reply using data recieved in the transaction handle.
    @(posedge clk_i);
  end
    // Wait for next transfer then gather info from intiator about the transfer.
    // Place the data into the responder_trans handle.
    @(posedge clk_i);
    @(posedge clk_i);
    first_transfer = 0;
  endtask
// pragma uvmf custom respond_and_wait_for_next_transfer end

 
endinterface

// pragma uvmf custom external begin
// pragma uvmf custom external end

