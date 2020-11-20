#include <stdio.h>
#include <netdb.h>

int main() {
    LPHOSTENT host;
    WSADATA wsaData;
    
    WSAStartup(2 , &wsaData);
    host = gethostbyname("pop.mail.yahoo.co.jp");
    if (host == NULL) {
        printf("NG\n");
    } else {
        printf("OK\n");
        printf("%s\n", host->h_name);
    }
    WSACleanup();
    return 0;
}
