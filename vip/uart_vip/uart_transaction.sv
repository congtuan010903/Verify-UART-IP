class uart_transaction extends uvm_sequence_item;

	//--------------------------------------------
	// Typedef: direction_enum
	//--------------------------------------------	
	typedef enum
	{
		DIR_TX,
		DIR_RX
	} direction_enum;

	//--------------------------------------------
	// Field: start, data, parity, stop, direction,...
	//--------------------------------------------
	rand bit						start;
	rand bit [8:0]			data;	
	rand bit						parity;
	rand bit [1:0]			stop;
	rand bit						start_error;
	rand bit						data_error;
	rand bit						parity_error;
	rand bit						stop_error;
	rand bit [3:0]      data_error_pos;	
	rand direction_enum direction;
	uart_configuration  current_config;
	
	//-------------------------------------------
	// UVM automation macros
 	//------------------------------------------
	`uvm_object_utils_begin(uart_transaction)
		`uvm_field_int(start,          UVM_ALL_ON)
		`uvm_field_int(data, 	         UVM_ALL_ON)
		`uvm_field_int(parity,         UVM_ALL_ON)
		`uvm_field_int(stop, 	         UVM_ALL_ON)
		`uvm_field_int(start_error,    UVM_ALL_ON)
		`uvm_field_int(parity_error,	 UVM_ALL_ON)
		`uvm_field_int(stop_error,  	 UVM_ALL_ON)
		`uvm_field_enum(direction_enum, direction, UVM_ALL_ON)
	`uvm_object_utils_end

	//---------------------------------------------
	// Constraint
	//---------------------------------------------
	constraint no_errors_c {
		soft start_error  == 0;
		soft parity_error == 0;
		soft stop_error   == 0;
	}
	
	//--------------------------------------------
	// Constructor: new
	//--------------------------------------------
	function new(string name = "uart_transaction");
		super.new(name);
	endfunction: new

endclass: uart_transaction
