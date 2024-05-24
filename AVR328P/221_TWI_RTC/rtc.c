/***************************************************************************************************
                                   ExploreEmbedded    
****************************************************************************************************
 * File:   rtc.c
 * Version: 15.0
 * Author: ExploreEmbedded
 * Website: http://www.exploreembedded.com/wiki
 * Description: Contains the library functions for RTC-Ds1307 date and time read write

The libraries have been tested on ExploreEmbedded development boards. We strongly believe that the 
library works on any of development boards for respective controllers. However, ExploreEmbedded 
disclaims any kind of hardware failure resulting out of usage of libraries, directly or indirectly.
Files may be subject to change without prior notice. The revision history contains the information 
related to updates. 


GNU GENERAL PUBLIC LICENSE: 
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

Errors and omissions should be reported to codelibraries@exploreembedded.com
***************************************************************************************************/



/***************************************************************************************************
                             Revision History
****************************************************************************************************
15.0: Initial version 
***************************************************************************************************/

#include "rtc.h"
#include "i2c.h"





/***************************************************************************************************
                         void RTC_Init(void)
****************************************************************************************************
 * I/P Arguments: none.
 * Return value    : none

 * description :This function is used to Initialize the Ds1307 RTC.
***************************************************************************************************/
void RTC_Init(void)
{
    i2cInit();                             // Initialize the I2c module.
    i2cStart();                            // Start I2C communication

    i2cSend(C_Ds1307WriteMode_U8);        // Connect to DS1307 by sending its ID on I2c Bus
    i2cSend(C_Ds1307ControlRegAddress_U8);// Select the Ds1307 ControlRegister to configure Ds1307

    i2cSend(0x00);                        // Write 0x00 to Control register to disable SQW-Out

    i2cStop();                             // Stop I2C communication after initializing DS1307
}














/***************************************************************************************************
                    void RTC_SetDateTime(rtc_t *rtc)
****************************************************************************************************
 * I/P Arguments: rtc_t *: Pointer to structure of type rtc_t. Structure contains hour,min,sec,day,date,month and year 
 * Return value    : none

 * description  :This function is used to update the Date and time of Ds1307 RTC.
                 The new Date and time will be updated into the non volatile memory of Ds1307.
        Note: The date and time should be of BCD format, 
             like 0x12,0x39,0x26 for 12hr,39min and 26sec.    
                  0x15,0x08,0x47 for 15th day,8th month and 47th year.                 
***************************************************************************************************/
void RTC_SetDateTime(rtc_t *rtc)
{
    i2cStart();                          // Start I2C communication

    i2cSend(C_Ds1307WriteMode_U8);      // connect to DS1307 by sending its ID on I2c Bus
    i2cSend(C_Ds1307SecondRegAddress_U8); // Request sec RAM address at 00H

    i2cSend(rtc->sec);                    // Write sec from RAM address 00H
    i2cSend(rtc->min);                    // Write min from RAM address 01H
    i2cSend(rtc->hour);                    // Write hour from RAM address 02H
    i2cSend(rtc->weekDay);                // Write weekDay on RAM address 03H
    i2cSend(rtc->date);                    // Write date on RAM address 04H
    i2cSend(rtc->month);                    // Write month on RAM address 05H
    i2cSend(rtc->year);                    // Write year on RAM address 06h

    i2cStop();                              // Stop I2C communication after Setting the Date
}







/***************************************************************************************************
                     void RTC_GetDateTime(rtc_t *rtc)
****************************************************************************************************
 * I/P Arguments: rtc_t *: Pointer to structure of type rtc_t. Structure contains hour,min,sec,day,date,month and year 
 * Return value    : none

 * description  :This function is used to get the Date(d,m,y) from Ds1307 RTC.

    Note: The date and time read from Ds1307 will be of BCD format, 
          like 0x12,0x39,0x26 for 12hr,39min and 26sec.    
               0x15,0x08,0x47 for 15th day,8th month and 47th year.              
***************************************************************************************************/
void RTC_GetDateTime(rtc_t *rtc)
{
    i2cStart();                            // Start I2C communication

    i2cSend(C_Ds1307WriteMode_U8);        // connect to DS1307 by sending its ID on I2c Bus
    i2cSend(C_Ds1307SecondRegAddress_U8); // Request Sec RAM address at 00H

    i2cStop();                                // Stop I2C communication after selecting Sec Register

    i2cStart();                            // Start I2C communication
    i2cSend(C_Ds1307ReadMode_U8);            // connect to DS1307(Read mode) by sending its ID

    rtc->sec = i2cReadAck();                // read second and return Positive ACK
    rtc->min = i2cReadAck();                 // read minute and return Positive ACK
    rtc->hour= i2cReadAck();               // read hour and return Negative/No ACK
    rtc->weekDay = i2cReadAck();           // read weekDay and return Positive ACK
    rtc->date= i2cReadAck();              // read Date and return Positive ACK
    rtc->month=i2cReadAck();            // read Month and return Positive ACK
    rtc->year =i2cReadNoAck();             // read Year and return Negative/No ACK

    i2cStop();                              // Stop I2C communication after reading the Date
}
