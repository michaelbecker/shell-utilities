#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void usage(void)
{
    printf("mksig <DEFINE_NAME> <SIGNATURE_STRING>\n");
    exit(-1);
}


int main (int argc, char *argv[])
{
    //--------------------------
    char *define_name;
    char *signature;
    int length;
    int i;
    //--------------------------

    if (argc < 3) {
        usage();
    }

    define_name = argv[1];
    signature = argv[2];

    length = strlen(signature);

    if (strlen(signature) > 4) {
        printf("Signature must be 4 characters or less.\n");
        return -1;
    }

    printf("#define %s 0x", argv[1]);

    for (i = 0; i < length; i++)
        printf("%02X", signature[i]);

    for ( ; i < 4; i++)
        printf("%02X", 0);

    printf("\n");

    return 0;
}
