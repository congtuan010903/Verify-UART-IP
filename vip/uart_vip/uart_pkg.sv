//=============================================================================
// Project       : UART VIP
//=============================================================================
// Filename      : uart_pkg.sv
// Author        : 
// Company       : NO
// Date          :
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_UART_PKG__SV
`define GUARD_UART_PKG__SV
package uart_pkg;
  import uvm_pkg::*;

  // Include your file
	`include "uart_configuration.sv"
	`include "uart_transaction.sv"
	`include "uart_driver.sv"
	`include "uart_sequencer.sv"
	`include "uart_monitor1.sv"
	`include "uart_agent.sv"
endpackage: uart_pkg

`endif

