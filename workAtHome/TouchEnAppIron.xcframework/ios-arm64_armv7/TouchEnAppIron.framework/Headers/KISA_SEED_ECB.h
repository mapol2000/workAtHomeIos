/*******************************************************************************
*
* FILE:         KISA_SEED_ECB.h
*
* DESCRIPTION:  header file for KISA_SEED_ECB.c
*
*******************************************************************************/

#ifndef _SEED_H
#define _SEED_H

/******************************* Include files ********************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef  __cplusplus
extern "C" {
#endif

/******************************* Type Definitions *****************************/

// If your machine uses different data types, you must change them to proper ones.
#ifndef TYPE_DEFINITION
    #define TYPE_DEFINITION
    #if defined(__alpha)
        typedef unsigned int        DWORD;		// unsigned 4-byte data type
        typedef unsigned short      WORD;		// unsigned 2-byte data type
    #else
        typedef unsigned long int   DWORD;		// unsigned 4-byte data type
        typedef unsigned short int  WORD;		// unsigned 2-byte data type
    #endif
    typedef unsigned char           BYTE;		// unsigned 1-byte data type
#endif


/***************************** Endianness Define ******************************/
// If endianness is not defined correctly, you must modify here.
// SEED uses the Little endian as a defalut order

#if __alpha__	||	__alpha	||	__i386__	||	i386	||	_M_I86	||	_M_IX86	||	\
	__OS2__		||	sun386	||	__TURBOC__	||	vax		||	vms		||	VMS		||	__VMS 
#define LITTLE_ENDIAN
#else
#define BIG_ENDIAN
#endif


/**************************** Constant Definitions ****************************/

#define NoRounds         16						// the number of rounds
#define NoRoundKeys      (NoRounds*2)			// the number of round-keys
#define SeedBlockSize    16    					// block length in bytes
#define SeedBlockLen     128   					// block length in bits


/******************************** Common Macros *******************************/

// macroses for left or right rotations
#if defined(_MSC_VER)
    #define ROTL(x, n)     (_lrotl((x), (n)))		// left rotation
    #define ROTR(x, n)     (_lrotr((x), (n)))		// right rotation
#else
    #define ROTL(x, n)     (((x) << (n)) | ((x) >> (32-(n))))		// left rotation
    #define ROTR(x, n)     (((x) >> (n)) | ((x) << (32-(n))))		// right rotation
#endif

// macroses for converting endianess
#define EndianChange(dwS)                       \
    ( (ROTL((dwS),  8) & (DWORD)0x00ff00ff) |   \
      (ROTL((dwS), 24) & (DWORD)0xff00ff00) )


/*************************** Function Declarations ****************************/

void SEED_Encrypt_ECB(		/* encryption function */
		BYTE *pbData, 				// [in,out]	data to be encrypted
		DWORD *pdwRoundKey			// [in]			round keys for encryption
		);
    
void SEED_Decrypt_ECB(		/* decryption function */
		BYTE *pbData, 				// [in,out]	data to be decrypted
		DWORD *pdwRoundKey			// [in]			round keys for decryption
		);
    
void SEED_KeySchedKey(		/* key scheduling function */
		DWORD *pdwRoundKey, 		// [out]		round keys for encryption or decryption
		BYTE *pbUserKey				// [in]			secret user key 
		);

#define    KS_SYM_PADDING_NO                1
#define    KS_SYM_PADDING_ZERO                2    // for CBCMAC
#define    KS_SYM_PADDING_HASH                3
#define    KS_SYM_PADDING_PKCS                4
#define KS_SYM_ERR                                                        -4000
#define KS_SYM_GETPADLEN_INVALID_PKCS_PADDING_ERR                        (KS_SYM_ERR - 8)
#define KS_SYM_GETPADLEN_INVALID_HASH_PADDING_ERR                        (KS_SYM_ERR - 7)

typedef unsigned char U8;
#define U32 unsigned int
int KS_SYM_Padding(U8 *data, U32 dataLength, int padding, U32 blockSize);
int KS_SYM_GetPaddingLength(U8 *input, U32 inputLength, int padding, U32 blockSize);
/*************************** END OF FILE **************************************/

#ifdef  __cplusplus
}
#endif

#endif
