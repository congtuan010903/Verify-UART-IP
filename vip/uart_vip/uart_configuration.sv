class uart_configuration extends uvm_object;

	//--------------------------------------------
	// Typedef: parity_mode_enum
	//--------------------------------------------
	typedef enum
	{
		PARITY_ODD, 
		PARITY_EVEN, 
		PARITY_NONE
	} parity_mode_enum;

	//-------------------------------------------------------------
	// Field: baud_rate, data_width, stop_bits, active, parity_mode
	//-------------------------------------------------------------
	rand int 						 baud_rate 		= 9600;
	rand int 						 data_width 	= 5;
	rand int 						 stop_bits 		= 1;
	rand int 						 data_er_pos  = 3;
	rand bit 						 active				= 1;
	rand bit             data_error   = 0;

	parity_mode_enum parity_mode 	= PARITY_NONE;
	
	//-------------------------------------------------------------
	// Constraint: baud_rate, data_width, stop_bits
	//-------------------------------------------------------------
	constraint valid_baud_rate 
	{
		baud_rate inside {[1:115200]};
	}

	constraint valid_data_width
	{
		if(parity_mode == PARITY_NONE)
			data_width inside	{[5:9]};
		else
			data_width inside {[5:9]};
	}

	constraint valid_stop_bits
	{
		stop_bits inside {1, 2};
	}
	
	constraint valid_data_er_pos
	{
		data_er_pos < data_width;
	}			
	
	//-----------------------------------------------------------
	// UVM automation macros
	//-----------------------------------------------------------	
	`uvm_object_utils_begin(uart_configuration)
		`uvm_field_int(baud_rate, 	UVM_ALL_ON | UVM_DEC)
		`uvm_field_int(data_width,  UVM_ALL_ON)
		`uvm_field_int(stop_bits,		UVM_ALL_ON)
		`uvm_field_int(active,			UVM_ALL_ON)
		`uvm_field_enum(parity_mode_enum, parity_mode, UVM_ALL_ON)
	`uvm_object_utils_end
	
	//------------------------------------------------
	// Constructor: new
	//------------------------------------------------
	function new(string name = "uart_configuration");
		super.new(name);
	endfunction: new

endclass: uart_configuration
