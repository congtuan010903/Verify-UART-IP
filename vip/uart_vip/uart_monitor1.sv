class uart_monitor extends uvm_monitor;
	
	`uvm_component_utils(uart_monitor)

	virtual uart_if 	 uart_vif;
	uart_configuration uart_config;

	uvm_analysis_port #(uart_transaction) item_observed_port;

	//---------------------------------------
	// Constructor
	//---------------------------------------
	function new(string name = "uart_monitor", uvm_component parent);
		super.new(name, parent);
		item_observed_port = new("item_observed_port", this);
	endfunction: new
	
	//-----------------------------------------
	// Function: build_phase
	//-----------------------------------------
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// get virtual interface
		if(!uvm_config_db #(virtual uart_if)::get(this,"","uart_vif",uart_vif))
			`uvm_fatal(get_type_name(),$sformatf("Failed to get interface from uvm_config_db. Please check!"))

		// get uart_configuration
		if(!uvm_config_db #(uart_configuration)::get(this,"","uart_config",uart_config))
			`uvm_fatal(get_type_name(),$sformatf("Failed to get configuration from uvm_config_db. Please check!"))
	endfunction: build_phase

	//--------------------------------------------
	// Task: run_phase
	//--------------------------------------------
	virtual task run_phase(uvm_phase phase);
		if(uart_config.active === 1)
			fork
				monitor_rx();
				monitor_tx();
			join
		else
			monitor_rx();
	endtask: run_phase

	//-------------------------------------------
	// Task: monitor_rx
	//-------------------------------------------
	task monitor_rx();
		`uvm_info(get_type_name(),"Monitoring RX...",UVM_LOW)
		forever begin
			bit							 exp_parity;
			real  					 bit_period;
			uart_transaction uart_trans;

			uart_trans 					 = uart_transaction::type_id::create("uart_trans");
			uart_trans.direction = uart_transaction::DIR_RX;
				
			if(uart_vif.rx !== 1'b1) begin
				wait(uart_vif.rx === 1);
			end

			@(negedge uart_vif.rx);
			bit_period 					 = (1.0e9/uart_config.baud_rate);
			`uvm_info(get_type_name(),"Detect negedge of start bit on RX of VIP",UVM_LOW)
			`uvm_info(get_type_name(),$sformatf("baud rate: %0d",uart_config.baud_rate),UVM_LOW)
			`uvm_info(get_type_name(),$sformatf("bit period: %0d",bit_period),UVM_LOW)		
			// capture start bit
			#((0.5*bit_period)*1ns);
			uart_trans.start = uart_vif.rx;
			`uvm_info(get_type_name(),"Capture start bit on RX of VIP",UVM_LOW)
			if(uart_trans.start !== 0)
				`uvm_error(get_type_name(),"Detect error on start bit on RX of VIP")
	
			// capture data bit
			for(int i = 0; i < uart_config.data_width; i++) begin
				#((bit_period)*1ns);
				uart_trans.data[i] = uart_vif.rx;
				`uvm_info(get_type_name(),$sformatf("Capture data bit on RX of VIP: %0b",uart_trans.data[i]),UVM_LOW)
			end
			// capture parity bit
			if(uart_config.parity_mode != uart_configuration::PARITY_NONE) begin
				#(bit_period*1ns);
				exp_parity = calculate_parity(uart_trans.data, uart_config.parity_mode);
				uart_trans.parity = uart_vif.rx;
				`uvm_info(get_type_name(),$sformatf("Capture parity bit on RX of VIP: %0b",uart_trans.parity),UVM_LOW)
				if(uart_trans.parity != exp_parity)
					`uvm_error(get_type_name(),"Detect error on parity")
			end
			// capture stop bit
			for(int i = 0; i < uart_config.stop_bits; i++) begin
				#(bit_period*1ns);
			  uart_trans.stop[i] = uart_vif.rx;
				`uvm_info(get_type_name(),"Capture stop bit on RX of VIP",UVM_LOW)
				if(uart_trans.stop[i] !== 1) `uvm_error(get_type_name(),$sformatf("Detect error on stop bit %0d",i+1))	
			end
			uart_trans.current_config = uart_config;
			// send transaction to scoreboard
			`uvm_info(get_type_name(), $sformatf("Capture transaction RX: \n %s",uart_trans.sprint()), UVM_LOW)
			item_observed_port.write(uart_trans);
		end
	endtask: monitor_rx;

	//-------------------------------------------
	// Task: monitor_tx
	//-------------------------------------------
	task monitor_tx();
		forever begin
			bit              exp_parity;
			real  					 bit_period;
			uart_transaction uart_trans;
	
			uart_trans 					 = uart_transaction::type_id::create("uart_trans");
			uart_trans.direction = uart_transaction::DIR_TX;
			
			if(uart_vif.tx !== 1'b1) begin
				wait(uart_vif.tx === 1);
			end

			@(negedge uart_vif.tx);
			bit_period 					 = (1.0e9/uart_config.baud_rate);
			`uvm_info(get_type_name(),"Detect negedge of start bit on TX of VIP",UVM_LOW)
			`uvm_info(get_type_name(),$sformatf("baud rate: %0d",uart_config.baud_rate),UVM_LOW)
			`uvm_info(get_type_name(),$sformatf("bit period: %0d",bit_period),UVM_LOW)

			// capture start bit
			#(0.5*bit_period*1ns);
			`uvm_info(get_type_name(),"Capture start bit on TX of VIP",UVM_LOW)
			uart_trans.start = uart_vif.tx;
			// capture data bit
			for(int i = 0; i < uart_config.data_width; i++) begin
				#(bit_period*1ns);
				uart_trans.data[i] = uart_vif.tx;
				`uvm_info(get_type_name(),$sformatf("Capture data bit on TX of VIP: %0b",uart_trans.data[i]),UVM_LOW)
			end
			// capture parity bit
			if(uart_config.parity_mode != uart_configuration::PARITY_NONE) begin
				#(bit_period*1ns);
				uart_trans.parity = uart_vif.tx;
				`uvm_info(get_type_name(),$sformatf("Capture parity bit on TX of VIP: %0b",uart_trans.parity),UVM_LOW)
				exp_parity = calculate_parity(uart_trans.data, uart_config.parity_mode);
				if(uart_trans.parity != exp_parity)
					uart_trans.parity_error = 1;
			end
			// capture stop bit
			for(int i = 0; i < uart_config.stop_bits; i++) begin
				#(bit_period*1ns);
				uart_trans.stop[i] = uart_vif.tx;
				`uvm_info(get_type_name(),$sformatf("Capture stop bit on TX of VIP: %0b",uart_trans.stop[i]),UVM_LOW)
			end
			// send transaction to scoreboard
			uart_trans.current_config = uart_config;
			`uvm_info(get_type_name(), $sformatf("Capture transaction TX: \n %s",uart_trans.sprint()), UVM_LOW)
			item_observed_port.write(uart_trans);
		end
	endtask: monitor_tx
	
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
	
	//-----------------------------------------
	// Function: update config
	//-----------------------------------------
	function void update_config(uart_configuration new_config);
		uart_config = new_config;
		`uvm_info(get_type_name(),"Monitor config updated",UVM_LOW)
	endfunction

endclass: uart_monitor
