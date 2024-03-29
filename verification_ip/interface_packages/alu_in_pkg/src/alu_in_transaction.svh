//----------------------------------------------------------------------
// Created with uvmf_gen version 2022.3
//----------------------------------------------------------------------
// pragma uvmf custom header begin
// pragma uvmf custom header end
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//     
// DESCRIPTION: This class defines the variables required for an alu_in
//    transaction.  Class variables to be displayed in waveform transaction
//    viewing are added to the transaction viewing stream in the add_to_wave
//    function.
//
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//
class alu_in_transaction #(
      int ALU_IN_OP_WIDTH = 8
      )
 extends uvmf_transaction_base;

  `uvm_object_param_utils( alu_in_transaction #(
                           ALU_IN_OP_WIDTH
                           )
)

  rand alu_in_op_t op ;
  rand bit [ALU_IN_OP_WIDTH-1:0] a ;
  rand bit [ALU_IN_OP_WIDTH-1:0] b ;

  //Constraints for the transaction variables:
  constraint valid_op_c { op inside {add_op, and_op, xor_op, mul_op}; }

  // pragma uvmf custom class_item_additional begin
  // pragma uvmf custom class_item_additional end

  // ****************************************************************************
  // FUNCTION : new()
  // This function is the standard SystemVerilog constructor.
  //
  function new( string name = "" );
    super.new( name );
  endfunction

  // ****************************************************************************
  // FUNCTION: convert2string()
  // This function converts all variables in this class to a single string for 
  // logfile reporting.
  //
  virtual function string convert2string();
    // pragma uvmf custom convert2string begin
    // UVMF_CHANGE_ME : Customize format if desired.
    return $sformatf("op:0x%x a:0x%x b:0x%x ",op,a,b);
    // pragma uvmf custom convert2string end
  endfunction

  //*******************************************************************
  // FUNCTION: do_print()
  // This function is automatically called when the .print() function
  // is called on this class.
  //
  virtual function void do_print(uvm_printer printer);
    // pragma uvmf custom do_print begin
    // UVMF_CHANGE_ME : Current contents of do_print allows for the use of UVM 1.1d, 1.2 or P1800.2.
    // Update based on your own printing preference according to your preferred UVM version
    $display(convert2string());
    // pragma uvmf custom do_print end
  endfunction

  //*******************************************************************
  // FUNCTION: do_compare()
  // This function is automatically called when the .compare() function
  // is called on this class.
  //
  virtual function bit do_compare (uvm_object rhs, uvm_comparer comparer);
    alu_in_transaction #(
        .ALU_IN_OP_WIDTH(ALU_IN_OP_WIDTH)
        )
 RHS;
    if (!$cast(RHS,rhs)) return 0;
    // pragma uvmf custom do_compare begin
    // UVMF_CHANGE_ME : Eliminate comparison of variables not to be used for compare
    return (super.do_compare(rhs,comparer)
            &&(this.op == RHS.op)
            &&(this.a == RHS.a)
            &&(this.b == RHS.b)
            );
    // pragma uvmf custom do_compare end
  endfunction

  //*******************************************************************
  // FUNCTION: do_copy()
  // This function is automatically called when the .copy() function
  // is called on this class.
  //
  virtual function void do_copy (uvm_object rhs);
    alu_in_transaction #(
        .ALU_IN_OP_WIDTH(ALU_IN_OP_WIDTH)
        )
 RHS;
    assert($cast(RHS,rhs));
    // pragma uvmf custom do_copy begin
    super.do_copy(rhs);
    this.op = RHS.op;
    this.a = RHS.a;
    this.b = RHS.b;
    // pragma uvmf custom do_copy end
  endfunction

  // ****************************************************************************
  // FUNCTION: add_to_wave()
  // This function is used to display variables in this class in the waveform 
  // viewer.  The start_time and end_time variables must be set before this 
  // function is called.  If the start_time and end_time variables are not set
  // the transaction will be hidden at 0ns on the waveform display.
  // 
  virtual function void add_to_wave(int transaction_viewing_stream_h);
    `ifdef QUESTA
    if (transaction_view_h == 0) begin
      transaction_view_h = $begin_transaction(transaction_viewing_stream_h,"alu_in_transaction",start_time);
    end
    super.add_to_wave(transaction_view_h);
    // pragma uvmf custom add_to_wave begin
    // UVMF_CHANGE_ME : Color can be applied to transaction entries based on content, example below
    case(op)
       no_op  : $add_color(transaction_view_h,"grey");
       add_op : $add_color(transaction_view_h,"green");
       and_op : $add_color(transaction_view_h,"orange");
       xor_op : $add_color(transaction_view_h,"red");
       mul_op : $add_color(transaction_view_h,"yellow");
       rst_op : $add_color(transaction_view_h,"blue");
       default : $add_color(transaction_view_h,"cyan");
    endcase
    // UVMF_CHANGE_ME : Eliminate transaction variables not wanted in transaction viewing in the waveform viewer
    $add_attribute(transaction_view_h,op,"op");
    $add_attribute(transaction_view_h,a,"a");
    $add_attribute(transaction_view_h,b,"b");
    // pragma uvmf custom add_to_wave end
    $end_transaction(transaction_view_h,end_time);
    $free_transaction(transaction_view_h);
    `endif // QUESTA
  endfunction

endclass

// pragma uvmf custom external begin
// pragma uvmf custom external end

