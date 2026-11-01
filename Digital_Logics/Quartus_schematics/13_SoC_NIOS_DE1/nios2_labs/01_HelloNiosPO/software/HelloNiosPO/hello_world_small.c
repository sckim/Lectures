#include "stdio.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"

int main()
{ 
  printf("Hello from Nios II world!\n");

  IOWR_ALTERA_AVALON_PIO_DATA(LEDS_BASE, 0x03FF);

  printf("LEDs value : 0x%X", IORD_ALTERA_AVALON_PIO_DATA(LEDS_BASE));
  /* Event loop never exits. */
  while (1);

  return 0;
}
