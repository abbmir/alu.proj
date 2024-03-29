//----------------------------------------------------------------------
// Created with uvmf_gen version 2022.3
//----------------------------------------------------------------------
// pragma uvmf custom header begin
// pragma uvmf custom header end
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//
// Description: This file contains the top level and utility sequences
//     used by test_top. It can be extended to create derivative top
//     level sequences.
//
//----------------------------------------------------------------------
//
//----------------------------------------------------------------------
//


typedef alu_env_configuration  alu_env_configuration_t;

class alu_bench_sequence_base extends uvmf_sequence_base #(uvm_sequence_item);

  `uvm_object_utils( alu_bench_sequence_base );

  // pragma uvmf custom sequences begin

typedef alu_env_sequence_base #(
        .CONFIG_T(alu_env_configuration_t)
        )
        alu_env_sequence_base_t;
rand alu_env_sequence_base_t alu_env_seq;



  // UVMF_CHANGE_ME : Instantiate, construct, and start sequences as needed to create stimulus scenarios.
  // Instantiate sequences here
  typedef alu_in_random_sequence  alu_in_agent_random_seq_t;
  alu_in_agent_random_seq_t alu_in_agent_random_seq;
  // pragma uvmf custom sequences end

  // Sequencer handles for each active interface in the environment
  typedef alu_in_transaction  alu_in_agent_transaction_t;
  uvm_sequencer #(alu_in_agent_transaction_t)  alu_in_agent_sequencer; 


  // Top level environment configuration handle
  alu_env_configuration_t top_configuration;

  // Configuration handles to access interface BFM's
  alu_in_configuration  alu_in_agent_config;
  alu_out_configuration  alu_out_agent_config;

  // pragma uvmf custom class_item_additional begin
  // pragma uvmf custom class_item_additional end

  // ****************************************************************************
  function new( string name = "" );
    super.new( name );
    // Retrieve the configuration handles from the uvm_config_db

    // Retrieve top level configuration handle
    if ( !uvm_config_db#(alu_env_configuration_t)::get(null,UVMF_CONFIGURATIONS, "TOP_ENV_CONFIG",top_configuration) ) begin
      `uvm_info("CFG", "*** FATAL *** uvm_config_db::get can not find TOP_ENV_CONFIG.  Are you using an older UVMF release than what was used to generate this bench?",UVM_NONE);
      `uvm_fatal("CFG", "uvm_config_db#(alu_env_configuration_t)::get cannot find resource TOP_ENV_CONFIG");
    end

    // Retrieve config handles for all agents
    if( !uvm_config_db #( alu_in_configuration )::get( null , UVMF_CONFIGURATIONS , alu_in_agent_BFM , alu_in_agent_config ) ) 
      `uvm_fatal("CFG" , "uvm_config_db #( alu_in_configuration )::get cannot find resource alu_in_agent_BFM" )
    if( !uvm_config_db #( alu_out_configuration )::get( null , UVMF_CONFIGURATIONS , alu_out_agent_BFM , alu_out_agent_config ) ) 
      `uvm_fatal("CFG" , "uvm_config_db #( alu_out_configuration )::get cannot find resource alu_out_agent_BFM" )

    // Assign the sequencer handles from the handles within agent configurations
    alu_in_agent_sequencer = alu_in_agent_config.get_sequencer();



    // pragma uvmf custom new begin
    // pragma uvmf custom new end

  endfunction

  // ****************************************************************************
  virtual task body();
    // pragma uvmf custom body begin

    // Construct sequences here

    alu_env_seq = alu_env_sequence_base_t::type_id::create("alu_env_seq");

    alu_in_agent_random_seq     = alu_in_agent_random_seq_t::type_id::create("alu_in_agent_random_seq");
    fork
      alu_in_agent_config.wait_for_reset();
      alu_out_agent_config.wait_for_reset();
    join
    // Start RESPONDER sequences here
    fork
    join_none
    // Start INITIATOR sequences here
    fork
      repeat (250) alu_in_agent_random_seq.start(alu_in_agent_sequencer);
    join

alu_env_seq.start(top_configuration.vsqr);

    // UVMF_CHANGE_ME : Extend the simulation XXX number of clocks after 
    // the last sequence to allow for the last sequence item to flow 
    // through the design.
    fork
      alu_in_agent_config.wait_for_num_clocks(4000);
      alu_out_agent_config.wait_for_num_clocks(4000);
    join

    // pragma uvmf custom body end
  endtask

endclass

// pragma uvmf custom external begin
// pragma uvmf custom external end

