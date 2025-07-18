class uart_driver extends uvm_driver #(uart_transaction);

	`uvm_component_utils(uart_driver)
	
	virtual uart_if		 uart_vif;
	uart_configuration uart_config;
	
	//------------------------------------------
	// Constructor: new
	//------------------------------------------
	function new(string name = "uart_driver", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	//---------------------------------------------------------
	// Function: build_phase
	//---------------------------------------------------------
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// get virtual interface
		if(!uvm_config_db #(virtual uart_if)::get(this,"","uart_vif",uart_vif))
			`uvm_fatal(get_type_name(),$sformatf("Failed to get interface from uvm_config_db. Please check!"))
		// get uart_configuration
		if(!uvm_config_db #(uart_configuration)::get(this,"","uart_config",uart_config))
			`uvm_fatal(get_type_name(),$sformatf("Failed to get configuration from uvm_config_db. Please check!"))
	endfunction: build_phase

	//-------------------------------------------------------	
	// Task: run_phase
	//-------------------------------------------------------
	virtual task run_phase(uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(req);

			if(req.direction == uart_transaction::DIR_TX)
				send_uart_frame(req);
			else
				`uvm_error(get_type_name(),$sformatf("Ignoring RX transaction"))

			seq_item_port.item_done();
		end
	endtask: run_phase

	//-----------------------------------------------------
	// Task: send_uart_drame
	//-----------------------------------------------------
	task send_uart_frame(uart_transaction uart_trans);
		bit  b;
		real bit_period;
		bit_period 					 = (1.0e9/uart_config.baud_rate);
		`uvm_info(get_type_name(),$sformatf("baud rate: %0d",uart_config.baud_rate),UVM_LOW)
		`uvm_info(get_type_name(),$sformatf("bit period: %0d",bit_period),UVM_LOW)
		// idle state
		uart_vif.tx = 1;
		#(bit_period*1ns);
		// start bit
		uart_trans.start = uart_trans.start_error ? 1 : 0;
		uart_vif.tx = uart_trans.start;
		`uvm_info(get_type_name(),"Start drive start bit",UVM_LOW)
		#(bit_period*1ns);
		// data bits
    `uvm_info(get_type_name(),"Start drive data bit",UVM_LOW)
		for(int i = 0; i < uart_config.data_width; i++) begin
			if(uart_config.data_error && (i == uart_config.data_er_pos))
				uart_trans.data[i] = ~uart_trans.data[i];
			uart_vif.tx = uart_trans.data[i];
			#(bit_period*1ns);
		end
		// parity bit
		if(uart_config.parity_mode != uart_configuration::PARITY_NONE) begin
			`uvm_info(get_type_name(),"Start drive parity_bit",UVM_LOW)
			b = calculate_parity(uart_trans.data, uart_config.parity_mode);
			uart_trans.parity = uart_trans.parity_error ? ~b : b;
			uart_vif.tx = uart_trans.parity;
			#(bit_period*1ns);
		end
		// stop bits
		`uvm_info(get_type_name(),"Start drive stop bit", UVM_LOW)
		for(int i = 0; i < uart_config.stop_bits; i++) begin
			if(uart_trans.stop_error)
				uart_trans.stop[i] = 0;
			uart_vif.tx = uart_trans.stop[i];
			#(bit_period*1ns);
		end
	endtask: send_uart_frame

	//------------------------------------------------------
	// Function: calculate_parity
	//------------------------------------------------------
	function bit calculate_parity(bit [8:0]data, uart_configuration::parity_mode_enum parity_mode);
		bit parity = 0;	
		for(int i = 0; i < uart_config.data_width; i++) begin
			parity = parity^data[i];
		end
		case(parity_mode)
			uart_configuration::PARITY_ODD	 :return ~parity;
			uart_configuration::PARITY_EVEN  :return parity;
			default									 				 :return 0;
		endcase	
	endfunction: calculate_parity
	
	//------------------------------------------
	// Function: update config
	//------------------------------------------
	function void update_config(uart_configuration new_config);
		uart_config = new_config;
		`uvm_info(get_type_name(),"Driver config updated",UVM_LOW)
	endfunction

endclass: uart_driver
