#include "rtc.h"
#include "uart.h"
#include <util/delay.h>

int main(void) {
	stdout = &uart_output;
	stdin = &uart_input;

	rtc_t rtc;
	uart_init(9600UL);

	RTC_Init();
	rtc.hour = 0x10; //  10:40:20 am
	rtc.min = 0x40;
	rtc.sec = 0x00;

	rtc.date = 0x01; //1st Jan 2016
	rtc.month = 0x01;
	rtc.year = 0x16;
	rtc.weekDay = 5; // Friday: 5th day of week considering monday as first day.

	/*##### Set the time and Date only once. Once the Time and Date is set, comment these lines
	 and reflash the code. Else the time will be set every time the controller is reset*/
	RTC_SetDateTime(&rtc);  //  10:40:20 am, 1st Jan 2016

	/* Display the Time and Date continuously */
	while (1) {
		RTC_GetDateTime(&rtc);
		printf("\n\rtime:%2x:%2x:%2x  \nDate:%2x/%2x/%2x", (uint16_t) rtc.hour,
				(uint16_t) rtc.min, (uint16_t) rtc.sec, (uint16_t) rtc.date,
				(uint16_t) rtc.month, (uint16_t) rtc.year);
		_delay_ms(1000);
	}

	return (0);
}
