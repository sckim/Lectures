#include "stdio.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"

int main()
{ 
  unsigned int sw_status, sw_status_pre;

  printf("Hello Nios II GPIO!\n");

  sw_status = sw_status_pre = 0x00;

  /* Event loop never exits. */
  while (1){
	  sw_status = IORD_ALTERA_AVALON_PIO_DATA(SW_BASE);
	  IOWR_ALTERA_AVALON_PIO_DATA(LEDS_BASE, sw_status);
	  if( sw_status != sw_status_pre){
		  printf("SW values = 0x%X\n", sw_status);
		  sw_status_pre = sw_status;
	  }
  }

  return 0;
}
