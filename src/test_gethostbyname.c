#include <stdio.h>
#include <netdb.h>

int main() {
    struct hostent *host;
    
    host = gethostbyname("pop.mail.yahoo.co.jp");
    if (host == NULL) {
        printf("NG\n");
    } else {
        printf("OK\n");
        printf("%s\n", host->h_name);
    }
    return 0;
}
