#ifndef UART_H
#define UART_H

#include <stdio.h>
#include <stdlib.h>

void UART_Transmit(unsigned char data);
unsigned char UART_Receive(void);
void InitUART(unsigned long iBaudrate);

/* http://www.ermicro.com/blog/?p=325 */

FILE uart_output = FDEV_SETUP_STREAM(UART_Transmit, NULL, _FDEV_SETUP_WRITE);
FILE uart_input = FDEV_SETUP_STREAM(NULL, UART_Receive, _FDEV_SETUP_READ);

#endif // UART_H 
