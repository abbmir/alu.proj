//----------------------------------------------------------------------
// Created with uvmf_gen version 2022.3
//----------------------------------------------------------------------
// pragma uvmf custom header begin
// pragma uvmf custom header end
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//                                          
// DESCRIPTION: This file contains environment level sequences that will
//    be reused from block to top level simulations.
//
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//
class alu_env_sequence_base #( 
      type CONFIG_T
      ) extends uvmf_virtual_sequence_base #(.CONFIG_T(CONFIG_T));


  `uvm_object_param_utils( alu_env_sequence_base #(
                           CONFIG_T
                           ) );

  
// This alu_env_sequence_base contains a handle to a alu_env_configuration object 
// named configuration.  This configuration variable contains a handle to each 
// sequencer within each agent within this environment and any sub-environments.
// The configuration object handle is automatically assigned in the pre_body in the
// base class of this sequence.  The configuration handle is retrieved from the
// virtual sequencer that this sequence is started on.
// Available sequencer handles within the environment configuration:

  // Initiator agent sequencers in alu_environment:
    // configuration.alu_in_agent_config.sequencer
    // configuration.alu_out_agent_config.sequencer

  // Responder agent sequencers in alu_environment:


    typedef alu_in_random_sequence alu_in_agent_random_sequence_t;
    alu_in_agent_random_sequence_t alu_in_agent_rand_seq;

    typedef alu_out_random_sequence alu_out_agent_random_sequence_t;
    alu_out_agent_random_sequence_t alu_out_agent_rand_seq;




  // pragma uvmf custom class_item_additional begin
  // pragma uvmf custom class_item_additional end
  
  function new(string name = "" );
    super.new(name);
    alu_in_agent_rand_seq = alu_in_agent_random_sequence_t::type_id::create("alu_in_agent_rand_seq");
    alu_out_agent_rand_seq = alu_out_agent_random_sequence_t::type_id::create("alu_out_agent_rand_seq");


  endfunction

  virtual task body();

    if ( configuration.alu_in_agent_config.sequencer != null )
       repeat (25) alu_in_agent_rand_seq.start(configuration.alu_in_agent_config.sequencer);
    if ( configuration.alu_out_agent_config.sequencer != null )
       repeat (25) alu_out_agent_rand_seq.start(configuration.alu_out_agent_config.sequencer);


  endtask

endclass

// pragma uvmf custom external begin
// pragma uvmf custom external end

