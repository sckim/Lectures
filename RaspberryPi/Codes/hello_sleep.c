#include <stdio.h>
#include <unistd.h>

void main(void)
{
   int sec=0;
 
   printf("Hello, world!\n");

   while(1){
      printf("Elapsed time: %3d seconds\n", sec);
      sleep(1); 
      sec++; 
   }
}
