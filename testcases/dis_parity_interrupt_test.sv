class dis_parity_interrupt_test extends uart_base_test;
	`uvm_component_utils(dis_parity_interrupt_test)
	
	uvm_status_e                 status;
	uart_configuration           uart_config2;
	vip_tx_parity_error_sequence seq;

	//----------------------------------------
	// Constructor
	//----------------------------------------
	function new(string name = "dis_parity_interrupt_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	//-------------------------------------
	// run phase
	//-------------------------------------
	virtual task run_phase(uvm_phase phase);
		bit[7:0] rdata;
		phase.raise_objection(this);

		wait(ahb_vif.HRESETn === 1);

		// config VIP
		uart_config2 = uart_configuration::type_id::create("uart_config2");
		uart_config2.baud_rate   = 115200;
		uart_config2.data_width  = 8;
		uart_config2.parity_mode = uart_configuration::PARITY_EVEN;
		uart_config2.stop_bits   = 2;
		`uvm_info(get_type_name(),"UART agent updating...",UVM_LOW)
		env.uart_agt.update_config(uart_config2);
		// config DUT
		regmodel.IER.write(status,32'h00); #(50*1ns);
		regmodel.MDR.write(status,32'h00); #(50*1ns);
		regmodel.DLL.write(status,32'h36); #(50*1ns);
		regmodel.LCR.write(status,32'h3F); #(50*1ns);

		seq = vip_tx_parity_error_sequence::type_id::create("seq");
		seq.start(env.uart_agt.uart_seqcer);
		
		regmodel.FSR.read(status,rdata);
		if(rdata[4] === 1) // check parity error status
			`uvm_info(get_type_name(),"Parity bit error, parity_error_status is trigger",UVM_LOW)
		else
			`uvm_error(get_type_name(),"Parity bit error, parity_error_status must be trigger")
			
		if(uart_vif.interrupt === 1) // check interrupt
			`uvm_error(get_type_name(),"Parity bit error but Interrupt disable, cannot trigger")

		regmodel.RBR.read(status,rdata);
		env.uart_sb.update_rbr_data(rdata);

		phase.drop_objection(this);
	endtask

endclass
