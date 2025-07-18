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
		fork
			monitor_rx();
			if(uart_config.active == 1)
				monitor_tx();
		join
	endtask: run_phase

	//-------------------------------------------
	// Task: monitor_rx
	//-------------------------------------------
	task monitor_rx();
		forever begin

			logic   				 has_noise;
			logic   				 stable_bit;
			real  					 bit_period;
			real 						 time_out;
			uart_transaction uart_trans;
	
			bit_period 					 = 1e9 / uart_config.baud_rate;
			time_out						 = 1.5*bit_period;
			uart_trans 					 = uart_transaction::type_id::create("uart_trans");
			uart_trans.direction = uart_transaction::DIR_RX;

			fork: wait_start_bit
				begin
					@(negedge uart_vif.rx);
				end

				begin
				  #time_out;
					`uvm_error("uart_monitor_rx","Timeout waiting for start bit")
				end
			join_any

			disable wait_start_bit;

			// capture start bit
			check_noise_rx(bit_period, has_noise, stable_bit); // check noise for start bit
			if(has_noise) begin
				`uvm_error(get_type_name(),$sformatf("Noise detected on start bit"))
				uart_trans.start = 1'bx;
			end
			else uart_trans.start = stable_bit;
			// capture data bit
			for(int i = 0; i < uart_config.data_width; i++) begin
				check_noise_rx(bit_period, has_noise, stable_bit); // check noise for data bit
				if(has_noise) begin
					`uvm_error(get_type_name(),$sformatf("Noise detected on data bit"))
					uart_trans.data[i] = 1'bx;
				end
				else uart_trans.data[i] = stable_bit;
			end
			// capture parity bit
			if(uart_config.parity_mode != uart_configuration::PARITY_NONE) begin
				check_noise_rx(bit_period, has_noise, stable_bit); // check noise for parity bit
				if(has_noise) begin
					`uvm_error(get_type_name(),$sformatf("Noise detected on parity bit"))
					uart_trans.parity = 1'bx;
				end
				else uart_trans.parity = stable_bit;
			end
			// capture stop bit
			for(int i = 0; i < uart_config.stop_bits; i++) begin
				check_noise_rx(bit_period, has_noise, stable_bit); // check noise for stop bit
				if(has_noise) begin
					`uvm_error(get_type_name(),$sformatf("Noise detected on stop bit %0d",i))
					uart_trans.stop[i] = 1'bx;
				end
				else uart_trans.stop[i] = stable_bit;
				if(stable_bit != 1) `uvm_error(get_type_name(),"stop error")
			end
			// send transaction to scoreboard
			`uvm_info(get_type_name(), $sformatf("Capture transaction: \n %s",uart_trans.sprint()), UVM_LOW)
			item_observed_port.write(uart_trans,uart_config);
		end
	endtask: monitor_rx;

	//----------------------------------------
	// Task: check_noise_rx
	//----------------------------------------
	task automatic check_noise_rx(
		input  real			bit_period,
		output logic		has_noise,
		output logic		stable_bit
	);
		real sample_interval = bit_period / 4.0;
		logic [3:0] sample;
		
		for(int i = 0; i < 4; i++) begin
			sample[i] = uart_vif.rx;
			#sample_interval;
		end

		if(sample[0] == sample[1] && sample[1] == sample[2] && sample[2] == sample[3]) begin
			stable_bit = sample[0];
			has_noise	 = 0;
		end
		else begin
			stable_bit = 1'bx;
			has_noise = 1;
		end
	endtask: check_noise_rx

	//-------------------------------------------
	// Task: monitor_tx
	//-------------------------------------------
	task monitor_tx();
		forever begin

			logic   				 has_noise;
			logic 					 stable_bit;
			real  					 bit_period;
			real 						 time_out;
			uart_transaction uart_trans;
	
			bit_period 					 = 1e9 / uart_config.baud_rate;
			time_out						 = 1.5*bit_period;
			uart_trans 					 = uart_transaction::type_id::create("uart_trans");
			uart_trans.direction = uart_transaction::DIR_TX;

			fork: wait_start_bit
				begin
					@(negedge uart_vif.tx);
				end

				begin
				  #time_out;
					`uvm_error("uart_monitor_tx","Timeout waiting for start bit")
				end
			join_any

			disable wait_start_bit;

			// capture start bit
			check_noise_tx(bit_period, has_noise, stable_bit); // check noise for start bit
			if(has_noise) begin
				`uvm_error(get_type_name(),$sformatf("Noise detected on start bit"))
				uart_trans.start = 1'bx;
			end
			else uart_trans.start = stable_bit;
			// capture data bit
			for(int i = 0; i < uart_config.data_width; i++) begin
				check_noise_tx(bit_period, has_noise, stable_bit); // check noise for data bit
				if(has_noise) begin
					`uvm_error(get_type_name(),$sformatf("Noise detected on data bit"))
					uart_trans.data[i] = 1'bx;
				end
				else uart_trans.data[i] = stable_bit;
			end
			// capture parity bit
			if(uart_config.parity_mode != uart_configuration::PARITY_NONE) begin
				check_noise_tx(bit_period, has_noise, stable_bit); // check noise for parity bit
				if(has_noise) begin
					`uvm_error(get_type_name(),$sformatf("Noise detected on parity bit"))
					uart_trans.parity = 1'bx;
				end
				else uart_trans.parity = stable_bit;
			end
			// capture stop bit
			for(int i = 0; i < uart_config.stop_bits; i++) begin
				check_noise_tx(bit_period, has_noise, stable_bit); // check noise for stop bit
				if(has_noise) begin
					`uvm_error(get_type_name(),$sformatf("Noise detected on stop bit %0d",i))
					uart_trans.stop[i] = 1'bx;
				end
				else uart_trans.stop[i] = stable_bit;
			end
			// send transaction to scoreboard
			`uvm_info(get_type_name(), $sformatf("Capture transaction: \n %s",uart_trans.sprint()), UVM_LOW)
			item_observed_port.write(uart_trans);
		end
	endtask: monitor_tx

	//----------------------------------------
	// Task: check_noise_tx
	//----------------------------------------
	task automatic check_noise_tx(
		input  real			bit_period,
		output logic		has_noise,
		output logic		stable_bit
	);
		real sample_interval = bit_period / 4.0;
		logic [3:0] sample;
		
		for(int i = 0; i < 4; i++) begin
			sample[i] = uart_vif.tx;
			#sample_interval;
		end

		if(sample[0] == sample[1] && sample[1] == sample[2] && sample[2] == sample[3]) begin
			stable_bit = sample[0];
			has_noise	 = 0;
		end
		else begin
			stable_bit = 1'bx;
			has_noise = 1;
		end
	endtask: check_noise_tx

endclass: uart_monitor
