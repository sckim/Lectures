// commond anode 7 segments
// dot(always off), gfedcba
const unsigned char SEG[] = {0b11000000, 0b11111001,
                         0b10100100, 0b10110000,
                         0b10011001, 0b10010010,
                         0b10000010, 0b11111000,
                         0b10000000, 0b10010000,
                         0b10001000, 0b10000011,
                         0b10100111, 0b10100001,
                         0b10000110, 0b10001110};

void dispSeg(unsigned char ch)
{
  for(int i=0; i<8; i++) {
 	//digitalWrite(i, bitRead(SEG[ch], i));
    digitalWrite(i, ((~SEG[ch]>>i)& 0x01));
/*
                     0b11000000>>0 => 0b11000000
                     0b11000000>>1 => 0b01100000
                     0b11000000>>2 => 0b00110000
                       
                     0b11000000>>5 => 0b00000110
                     0b11000000>>6 => 0b00000011
                     0b11000000>>7 => 0b00000001
                       
*/    
    //digitalWrite(i, SEG[ch] & (0x01<<i));
/*
                     0b11000000 & 0b0000_0001 <= 0x01<<0
                     0b11000000 & 0b0000_0010 <= 0x01<<1
                     0b11000000 & 0b0000_0100                       
                     0b11000000 & 0b0000_1000  
                     0b11000000 & 0b0001_0000  
                     0b11000000 & 0b0010_0000  
                     0b11000000 & 0b0100_0000 <= 0x01<<6
                     0b11000000 & 0b1000_0000 <= 0x01<<7 
*/ 
  }
}

void setup()
{
  for(int i=0; i<8; i++) {
  	pinMode(i, OUTPUT);    // pin의 입출력 상태 결정
  	digitalWrite(i, HIGH); // 현재 pin 출력을 high
  }
}

void loop()
{
  static unsigned char num;
  
  dispSeg(num++);
  if( num>9 )
      num = 0;  
  delay(1000);
  
/* for loop example  
  for(unsigned char i=0; i<sizeof(SEG)/sizeof(unsigned char); i++ ) {
  	dispSeg(i);
    delay(500);
  }   
*/  
}
