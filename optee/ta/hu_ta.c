/*
 * hu-ta: Trusted Application cho head unit automotive (skeleton)
 *
 * Phase 3 sẽ hoàn thiện. Các command:
 *   CMD_GENERATE_KEY  - sinh key bên trong TEE (không bao giờ export private key)
 *   CMD_SIGN          - ký payload bằng key trong secure storage
 *   CMD_VERIFY        - verify signature
 *   CMD_GET_PUBLIC_KEY- trả về public key (được phép export)
 *   CMD_DELETE_KEY    - destroy key
 *
 * Build: dùng build TA theo OP-TEE dev kit (ta/mk/ta.mk trong optee_client).
 */
#include <tee_internal_api.h>
#include <tee_internal_api_extensions.h>

#define TA_NAME         "hu.ta"
#define TA_UUID \
    { 0x5c1a7c4a, 0x8b1e, 0x4f0a, \
        { 0x9a, 0x3b, 0x1d, 0x2e, 0x4f, 0x5a, 0x6b, 0x7c } }

/* Command IDs — client và TA phải khớp nhau */
#define CMD_GENERATE_KEY    0
#define CMD_SIGN            1
#define CMD_VERIFY          2
#define CMD_GET_PUBLIC_KEY  3
#define CMD_DELETE_KEY      4

/* TODO Phase 3: implement từng command bằng TEE Internal Core API
 * (TEE_AllocateTransientObject, TEE_GenerateKey, TEE_AsymmetricSignDigest...)
 * Key object được giữ trong transient/persistent object của TEE —
 * KHÔNG BAO GIỜ copy key material vào shared memory.
 */

TEE_Result TA_CreateEntryPoint(void)
{
    DMSG("hu-ta: create entry point");
    return TEE_SUCCESS;
}

void TA_DestroyEntryPoint(void)
{
    DMSG("hu-ta: destroy entry point");
}

TEE_Result TA_OpenSessionEntryPoint(uint32_t param_types,
                                    TEE_Param params[4],
                                    void **session_context)
{
    (void)param_types;
    (void)params;
    (void)session_context;
    IMSG("hu-ta: session opened");
    return TEE_SUCCESS;
}

void TA_CloseSessionEntryPoint(void *session_context)
{
    (void)session_context;
    IMSG("hu-ta: session closed");
}

TEE_Result TA_InvokeCommandEntryPoint(void *session_context,
                                      uint32_t command_id,
                                      uint32_t param_types,
                                      TEE_Param params[4])
{
    (void)session_context;
    (void)param_types;
    (void)params;

    switch (command_id) {
    case CMD_GENERATE_KEY:
    case CMD_SIGN:
    case CMD_VERIFY:
    case CMD_GET_PUBLIC_KEY:
    case CMD_DELETE_KEY:
        /* TODO Phase 3 */
        return TEE_ERROR_NOT_SUPPORTED;
    default:
        EMSG("hu-ta: unknown command %u", command_id);
        return TEE_ERROR_NOT_SUPPORTED;
    }
}
