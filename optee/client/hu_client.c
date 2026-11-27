/*
 * hu-client: Normal-world client gọi hu-ta qua TEE Client API (skeleton)
 *
 * Phase 3 sẽ hoàn thiện. Đây là phần sẽ được nhúng vào hu-app.
 * Client KHÔNG bao giờ thấy private key — chỉ nhận signature/public key.
 */
#include <err.h>
#include <stdio.h>
#include <string.h>
#include <tee_client_api.h>

/* Phải khớp với TA_UUID trong hu_ta.c */
#define TA_UUID \
    { 0x5c1a7c4a, 0x8b1e, 0x4f0a, \
        { 0x9a, 0x3b, 0x1d, 0x2e, 0x4f, 0x5a, 0x6b, 0x7c } }

#define CMD_GENERATE_KEY    0
#define CMD_SIGN            1
#define CMD_VERIFY          2
#define CMD_GET_PUBLIC_KEY  3
#define CMD_DELETE_KEY      4

int main(int argc, char *argv[])
{
    (void)argc;
    (void)argv;

    TEEC_Context ctx;
    TEEC_Session sess;
    TEEC_Result res;

    res = TEEC_InitializeContext("hu-ta", &ctx);
    if (res != TEEC_SUCCESS)
        errx(1, "TEEC_InitializeContext failed: 0x%x", res);

    res = TEEC_OpenSession(&ctx, &sess, &TA_UUID,
                           TEEC_LOGIN_PUBLIC, NULL, NULL, NULL);
    if (res != TEEC_SUCCESS)
        errx(1, "TEEC_OpenSession failed: 0x%x", res);

    /* TODO Phase 3: implement invoke cho từng command
     * - CMD_SIGN: shared memory chứa payload, nhận signature
     * - CMD_VERIFY: gửi payload + signature, nhận kết quả
     * Negative test: gửi param sai, thử export private key...
     */
    printf("hu-client: skeleton — TODO Phase 3\n");

    TEEC_CloseSession(&sess);
    TEEC_FinalizeContext(&ctx);
    return 0;
}
