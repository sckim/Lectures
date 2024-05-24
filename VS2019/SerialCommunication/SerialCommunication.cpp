// CommTest.cpp : 이 파일에는 'main' 함수가 포함됩니다. 거기서 프로그램 실행이 시작되고 종료됩니다.
//

#include <windows.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>

int main()
{
	BOOL   Status;
	char   ComPortName[] = "\\\\.\\COM1"; // Name of the Serial port(May Change) to be opened,
	HANDLE hComm;

	hComm = CreateFile(ComPortName,
		GENERIC_READ | GENERIC_WRITE,
		0, // Serial ports can't be shared so 0
		0, // NULL for Serial ports
		OPEN_EXISTING,
		0, //  0 means we are using NonOverlapped IO. FILE_FLAG_OVERLAPPED,
		NULL); // NULL for Serial port

	if (hComm == INVALID_HANDLE_VALUE)
		printf("\n   Error! - Port %s can't be opened", ComPortName);
	else
		printf("\n   Port %s Opened\n ", ComPortName);

	/*------------------------------- Setting the Parameters for the SerialPort ------------------------------*/

	DCB dcbSerialParams = { 0 };                        // Initializing DCB structure
	dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
	Status = GetCommState(hComm, &dcbSerialParams);     //retreives  the current settings

	if (Status == FALSE)
		printf("\n   Error! in GetCommState()");

	dcbSerialParams.BaudRate = CBR_57600;      // Setting BaudRate = 9600
	dcbSerialParams.ByteSize = 8;             // Setting ByteSize = 8
	dcbSerialParams.StopBits = ONESTOPBIT;    // Setting StopBits = 1
	dcbSerialParams.Parity = NOPARITY;      // Setting Parity = None 

	Status = SetCommState(hComm, &dcbSerialParams);  //Configuring the port according to settings in DCB 
	if (Status == FALSE)
	{
		printf("\n   Error! in Setting DCB Structure");
	}
	else
	{
		printf("\n   Setting DCB Structure Successfull\n");
		printf("\n       Baudrate = %d", dcbSerialParams.BaudRate);
		printf("\n       ByteSize = %d", dcbSerialParams.ByteSize);
		printf("\n       StopBits = %d", dcbSerialParams.StopBits);
		printf("\n       Parity   = %d", dcbSerialParams.Parity);
	}

	COMMTIMEOUTS timeouts = { 0 };

	timeouts.ReadIntervalTimeout = 50;
	timeouts.ReadTotalTimeoutConstant = 50;
	timeouts.ReadTotalTimeoutMultiplier = 10;
	timeouts.WriteTotalTimeoutConstant = 50;
	timeouts.WriteTotalTimeoutMultiplier = 10;

	if (SetCommTimeouts(hComm, &timeouts) == FALSE)
		printf("\n   Error! in Setting Time Outs");
	else
		printf("\n\n   Setting Serial Port Timeouts Successfull");

	/*----------------------------- Writing a Character to Serial Port----------------------------------------*/
	char   lpBuffer[] = "AA\r";		       // lpBuffer should be  char or byte array, otherwise write wil fail
	DWORD  dNoOFBytestoWrite;              // No of bytes to write into the port
	DWORD  dNoOfBytesWritten = 0;          // No of bytes written to the port

	dNoOFBytestoWrite = sizeof(lpBuffer); // Calculating the no of bytes to write into the port

	Status = WriteFile(hComm,               // Handle to the Serialport
		lpBuffer,            // Data to be written to the port 
		dNoOFBytestoWrite,   // No of bytes to write into the port
		&dNoOfBytesWritten,  // No of bytes written to the port
		NULL);

	if (Status == TRUE)
		printf("\n\n    %s - Written to %s", lpBuffer, ComPortName);
	else
		printf("\n\n   Error %d in Writing to Serial Port", GetLastError());

	/*------------------------------------ Setting Receive Mask ----------------------------------------------*/

	Status = SetCommMask(hComm, EV_RXCHAR | EV_TXEMPTY); //Configure Windows to Monitor the serial device for Character Reception

	if (Status == FALSE)
		printf("\n\n    Error! in Setting CommMask");
	else
		printf("\n\n    Setting CommMask successfull");


	/*------------------------------------ Setting WaitComm() Event   ----------------------------------------*/

	printf("\n\n    Waiting for Data Reception");

	DWORD dwEventMask;                     // Event mask to trigger
	char  SerialBuffer[256];               // Buffer Containing Rxed Data
	DWORD BytesRead;                     // Bytes read by ReadFile()
	char  TempChar;                        // Temperory Character
	int i = 0;


	Status = WaitCommEvent(hComm, &dwEventMask, NULL); //Wait for the character to be received

	/*-------------------------- Program will Wait here till a Character is received ------------------------*/
	if (Status == FALSE)
	{
		printf("\n    Error! in Setting WaitCommEvent()");
	}
	else //If  WaitCommEvent()==True Read the RXed data using ReadFile();
	{
		printf("\n\n    Characters Received");

		for (;;) {
			i = 0;
			
			ReadFile(hComm, &TempChar, sizeof(TempChar), &BytesRead, NULL);
			if (BytesRead) {
				do
				{
					Status = ReadFile(hComm, &TempChar, sizeof(TempChar), &BytesRead, NULL);
					SerialBuffer[i] = TempChar;
					i++;
					//} while (NoBytesRead > 0);
				} while (TempChar != '\n');

				// ------------Printing the RXed String to Console----------------------
				printf("\r\n    ");
				for (int j = 0; j < i - 1; j++)		// j < i-1 to remove the dupliated last character
					printf("%c", SerialBuffer[j]);
			}
			
			// check for keypress, and write any out the port.
			if (_kbhit()) {
				TempChar = _getch();
				printf("%c", TempChar);
				WriteFile(hComm, &TempChar, sizeof(TempChar), &BytesRead, NULL);
			}
		}
	}

	CloseHandle(hComm);//Closing the Serial Port
	printf("\n +==========================================+\n");
}
