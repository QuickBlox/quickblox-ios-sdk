/* gsasl.h --- Header file for GNU SASL Library.
 * Copyright (C) 2002-2012 Simon Josefsson
 *
 * This file is part of GNU SASL Library.
 *
 * GNU SASL Library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * GNU SASL Library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License License along with GNU SASL Library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 */

#ifndef GSASL_H
#define GSASL_H

#include <stdio.h>		/* FILE */
#include <stddef.h>		/* size_t */
#include <unistd.h>		/* ssize_t */

#ifndef GSASL_API
#if defined GSASL_BUILDING && defined HAVE_VISIBILITY && HAVE_VISIBILITY
#define GSASL_API __attribute__((__visibility__("default")))
#elif defined GSASL_BUILDING && defined _MSC_VER && ! defined GSASL_STATIC
#define GSASL_API __declspec(dllexport)
#elif defined _MSC_VER && ! defined GSASL_STATIC
#define GSASL_API __declspec(dllimport)
#else
#define GSASL_API
#endif
#endif

#ifdef __cplusplus
extern "C"
{
#endif

  /**
   * GSASL_VERSION
   *
   * Pre-processor symbol with a string that describe the header file
   * version number.  Used together with gsasl_check_version() to
   * verify header file and run-time library consistency.
   */
#define GSASL_VERSION "1.8.1"

  /**
   * GSASL_VERSION_MAJOR
   *
   * Pre-processor symbol with a decimal value that describe the major
   * level of the header file version number.  For example, when the
   * header version is 1.2.3 this symbol will be 1.
   *
   * Since: 1.1
   */
#define GSASL_VERSION_MAJOR 1

  /**
   * GSASL_VERSION_MINOR
   *
   * Pre-processor symbol with a decimal value that describe the minor
   * level of the header file version number.  For example, when the
   * header version is 1.2.3 this symbol will be 2.
   *
   * Since: 1.1
   */
#define GSASL_VERSION_MINOR 8

  /**
   * GSASL_VERSION_PATCH
   *
   * Pre-processor symbol with a decimal value that describe the patch
   * level of the header file version number.  For example, when the
   * header version is 1.2.3 this symbol will be 3.
   *
   * Since: 1.1
   */
#define GSASL_VERSION_PATCH 1

  /**
   * GSASL_VERSION_NUMBER
   *
   * Pre-processor symbol with a hexadecimal value describing the
   * header file version number.  For example, when the header version
   * is 1.2.3 this symbol will have the value 0x010203.
   *
   * Since: 1.1
   */
#define GSASL_VERSION_NUMBER 0x010801

  /* RFC 2222: SASL mechanisms are named by strings, from 1 to 20
   * characters in length, consisting of upper-case letters, digits,
   * hyphens, and/or underscores.  SASL mechanism names must be
   * registered with the IANA.
   */
  enum
  {
    GSASL_MIN_MECHANISM_SIZE = 1,
    GSASL_MAX_MECHANISM_SIZE = 20
  };
  extern GSASL_API const char *GSASL_VALID_MECHANISM_CHARACTERS;

  /**
   * Gsasl_rc:
   * @GSASL_OK: Successful return code, guaranteed to be always 0.
   * @GSASL_NEEDS_MORE: Mechanism expects another round-trip.
   * @GSASL_UNKNOWN_MECHANISM: Application requested an unknown mechanism.
   * @GSASL_MECHANISM_CALLED_TOO_MANY_TIMES: Application requested too
   *   many round trips from mechanism.
   * @GSASL_MALLOC_ERROR: Memory allocation failed.
   * @GSASL_BASE64_ERROR: Base64 encoding/decoding failed.
   * @GSASL_CRYPTO_ERROR: Cryptographic error.
   * @GSASL_SASLPREP_ERROR: Failed to prepare internationalized string.
   * @GSASL_MECHANISM_PARSE_ERROR: Mechanism could not parse input.
   * @GSASL_AUTHENTICATION_ERROR: Authentication has failed.
   * @GSASL_INTEGRITY_ERROR: Application data integrity check failed.
   * @GSASL_NO_CLIENT_CODE: Library was built with client functionality.
   * @GSASL_NO_SERVER_CODE: Library was built with server functionality.
   * @GSASL_NO_CALLBACK: Application did not provide a callback.
   * @GSASL_NO_ANONYMOUS_TOKEN: Could not get required anonymous token.
   * @GSASL_NO_AUTHID: Could not get required authentication
   *   identity (username).
   * @GSASL_NO_AUTHZID: Could not get required authorization identity.
   * @GSASL_NO_PASSWORD: Could not get required password.
   * @GSASL_NO_PASSCODE: Could not get required SecurID PIN.
   * @GSASL_NO_PIN: Could not get required SecurID PIN.
   * @GSASL_NO_SERVICE: Could not get required service name.
   * @GSASL_NO_HOSTNAME: Could not get required hostname.
   * @GSASL_NO_CB_TLS_UNIQUE: Could not get required tls-unique CB.
   * @GSASL_NO_SAML20_IDP_IDENTIFIER: Could not get required SAML IdP.
   * @GSASL_NO_SAML20_REDIRECT_URL: Could not get required SAML
   *   redirect URL.
   * @GSASL_NO_OPENID20_REDIRECT_URL: Could not get required OpenID
   *   redirect URL.
   * @GSASL_GSSAPI_RELEASE_BUFFER_ERROR: GSS-API library call error.
   * @GSASL_GSSAPI_IMPORT_NAME_ERROR: GSS-API library call error.
   * @GSASL_GSSAPI_INIT_SEC_CONTEXT_ERROR: GSS-API library call error.
   * @GSASL_GSSAPI_ACCEPT_SEC_CONTEXT_ERROR: GSS-API library call error.
   * @GSASL_GSSAPI_UNWRAP_ERROR: GSS-API library call error.
   * @GSASL_GSSAPI_WRAP_ERROR: GSS-API library call error.
   * @GSASL_GSSAPI_ACQUIRE_CRED_ERROR: GSS-API library call error.
   * @GSASL_GSSAPI_DISPLAY_NAME_ERROR: GSS-API library call error.
   * @GSASL_GSSAPI_UNSUPPORTED_PROTECTION_ERROR: An unsupported
   *   quality-of-protection layer was requeted.
   * @GSASL_GSSAPI_ENCAPSULATE_TOKEN_ERROR: GSS-API library call error.
   * @GSASL_GSSAPI_DECAPSULATE_TOKEN_ERROR: GSS-API library call error.
   * @GSASL_GSSAPI_INQUIRE_MECH_FOR_SASLNAME_ERROR: GSS-API library call error.
   * @GSASL_GSSAPI_TEST_OID_SET_MEMBER_ERROR: GSS-API library call error.
   * @GSASL_GSSAPI_RELEASE_OID_SET_ERROR: GSS-API library call error.
   * @GSASL_KERBEROS_V5_INIT_ERROR: Init error in KERBEROS_V5.
   * @GSASL_KERBEROS_V5_INTERNAL_ERROR: General error in KERBEROS_V5.
   * @GSASL_SHISHI_ERROR: Same as %GSASL_KERBEROS_V5_INTERNAL_ERROR.
   * @GSASL_SECURID_SERVER_NEED_ADDITIONAL_PASSCODE: SecurID mechanism
   *   needs an additional passcode.
   * @GSASL_SECURID_SERVER_NEED_NEW_PIN: SecurID mechanism
   *   needs an new PIN.
   *
   * Error codes for library functions.
   */
  typedef enum
  {
    GSASL_OK = 0,
    GSASL_NEEDS_MORE = 1,
    GSASL_UNKNOWN_MECHANISM = 2,
    GSASL_MECHANISM_CALLED_TOO_MANY_TIMES = 3,
    GSASL_MALLOC_ERROR = 7,
    GSASL_BASE64_ERROR = 8,
    GSASL_CRYPTO_ERROR = 9,
    GSASL_SASLPREP_ERROR = 29,
    GSASL_MECHANISM_PARSE_ERROR = 30,
    GSASL_AUTHENTICATION_ERROR = 31,
    GSASL_INTEGRITY_ERROR = 33,
    GSASL_NO_CLIENT_CODE = 35,
    GSASL_NO_SERVER_CODE = 36,
    GSASL_NO_CALLBACK = 51,
    GSASL_NO_ANONYMOUS_TOKEN = 52,
    GSASL_NO_AUTHID = 53,
    GSASL_NO_AUTHZID = 54,
    GSASL_NO_PASSWORD = 55,
    GSASL_NO_PASSCODE = 56,
    GSASL_NO_PIN = 57,
    GSASL_NO_SERVICE = 58,
    GSASL_NO_HOSTNAME = 59,
    GSASL_NO_CB_TLS_UNIQUE = 65,
    GSASL_NO_SAML20_IDP_IDENTIFIER = 66,
    GSASL_NO_SAML20_REDIRECT_URL = 67,
    GSASL_NO_OPENID20_REDIRECT_URL = 68,
    /* Mechanism specific errors. */
    GSASL_GSSAPI_RELEASE_BUFFER_ERROR = 37,
    GSASL_GSSAPI_IMPORT_NAME_ERROR = 38,
    GSASL_GSSAPI_INIT_SEC_CONTEXT_ERROR = 39,
    GSASL_GSSAPI_ACCEPT_SEC_CONTEXT_ERROR = 40,
    GSASL_GSSAPI_UNWRAP_ERROR = 41,
    GSASL_GSSAPI_WRAP_ERROR = 42,
    GSASL_GSSAPI_ACQUIRE_CRED_ERROR = 43,
    GSASL_GSSAPI_DISPLAY_NAME_ERROR = 44,
    GSASL_GSSAPI_UNSUPPORTED_PROTECTION_ERROR = 45,
    GSASL_KERBEROS_V5_INIT_ERROR = 46,
    GSASL_KERBEROS_V5_INTERNAL_ERROR = 47,
    GSASL_SHISHI_ERROR = GSASL_KERBEROS_V5_INTERNAL_ERROR,
    GSASL_SECURID_SERVER_NEED_ADDITIONAL_PASSCODE = 48,
    GSASL_SECURID_SERVER_NEED_NEW_PIN = 49,
    GSASL_GSSAPI_ENCAPSULATE_TOKEN_ERROR = 60,
    GSASL_GSSAPI_DECAPSULATE_TOKEN_ERROR = 61,
    GSASL_GSSAPI_INQUIRE_MECH_FOR_SASLNAME_ERROR = 62,
    GSASL_GSSAPI_TEST_OID_SET_MEMBER_ERROR = 63,
    GSASL_GSSAPI_RELEASE_OID_SET_ERROR = 64
      /* When adding new values, note that integers are not necessarily
         assigned monotonously increasingly. */
  } Gsasl_rc;

  /**
   * Gsasl_qop:
   * @GSASL_QOP_AUTH: Authentication only.
   * @GSASL_QOP_AUTH_INT: Authentication and integrity.
   * @GSASL_QOP_AUTH_CONF: Authentication, integrity and confidentiality.
   *
   * Quality of Protection types (DIGEST-MD5 and GSSAPI).  The
   * integrity and confidentiality values is about application data
   * wrapping.  We recommend that you use @GSASL_QOP_AUTH with TLS as
   * that combination is generally more secure and have better chance
   * of working than the integrity/confidentiality layers of SASL.
   */
  typedef enum
  {
    GSASL_QOP_AUTH = 1,
    GSASL_QOP_AUTH_INT = 2,
    GSASL_QOP_AUTH_CONF = 4
  } Gsasl_qop;

  /**
   * Gsasl_cipher:
   * @GSASL_CIPHER_DES: Cipher DES.
   * @GSASL_CIPHER_3DES: Cipher 3DES.
   * @GSASL_CIPHER_RC4: Cipher RC4.
   * @GSASL_CIPHER_RC4_40: Cipher RC4 with 40-bit keys.
   * @GSASL_CIPHER_RC4_56: Cipher RC4 with 56-bit keys.
   * @GSASL_CIPHER_AES: Cipher AES.
   *
   * Encryption types (DIGEST-MD5) for confidentiality services of
   * application data.  We recommend that you use TLS instead as it is
   * generally more secure and have better chance of working.
   */
  typedef enum
  {
    GSASL_CIPHER_DES = 1,
    GSASL_CIPHER_3DES = 2,
    GSASL_CIPHER_RC4 = 4,
    GSASL_CIPHER_RC4_40 = 8,
    GSASL_CIPHER_RC4_56 = 16,
    GSASL_CIPHER_AES = 32
  } Gsasl_cipher;

  /**
   * Gsasl_saslprep_flags:
   * @GSASL_ALLOW_UNASSIGNED: Allow unassigned code points.
   *
   * Flags for the SASLprep function, see gsasl_saslprep().  For
   * background, see the GNU Libidn documentation.
   */
  typedef enum
  {
    GSASL_ALLOW_UNASSIGNED = 1
  } Gsasl_saslprep_flags;

  /**
   * Gsasl:
   *
   * Handle to global library context.
   */
  typedef struct Gsasl Gsasl;

  /**
   * Gsasl_session:
   *
   * Handle to SASL session context.
   */
  typedef struct Gsasl_session Gsasl_session;

  /**
   * Gsasl_property:
   * @GSASL_AUTHID: Authentication identity (username).
   * @GSASL_AUTHZID: Authorization identity.
   * @GSASL_PASSWORD: Password.
   * @GSASL_ANONYMOUS_TOKEN: Anonymous identifier.
   * @GSASL_SERVICE: Service name
   * @GSASL_HOSTNAME: Host name.
   * @GSASL_GSSAPI_DISPLAY_NAME: GSS-API credential principal name.
   * @GSASL_PASSCODE: SecurID passcode.
   * @GSASL_SUGGESTED_PIN: SecurID suggested PIN.
   * @GSASL_PIN: SecurID PIN.
   * @GSASL_REALM: User realm.
   * @GSASL_DIGEST_MD5_HASHED_PASSWORD: Pre-computed hashed DIGEST-MD5
   *   password, to avoid storing passwords in the clear.
   * @GSASL_QOPS: Set of quality-of-protection values.
   * @GSASL_QOP: Quality-of-protection value.
   * @GSASL_SCRAM_ITER: Number of iterations in password-to-key hashing.
   * @GSASL_SCRAM_SALT: Salt for password-to-key hashing.
   * @GSASL_SCRAM_SALTED_PASSWORD: Pre-computed salted SCRAM key,
   *   to avoid re-computation and storing passwords in the clear.
   * @GSASL_CB_TLS_UNIQUE: Base64 encoded tls-unique channel binding.
   * @GSASL_SAML20_IDP_IDENTIFIER: SAML20 user IdP URL.
   * @GSASL_SAML20_REDIRECT_URL: SAML 2.0 URL to access in browser.
   * @GSASL_OPENID20_REDIRECT_URL: OpenID 2.0 URL to access in browser.
   * @GSASL_OPENID20_OUTCOME_DATA: OpenID 2.0 authentication outcome data.
   * @GSASL_SAML20_AUTHENTICATE_IN_BROWSER: Request to perform SAML 2.0
   *   authentication in browser.
   * @GSASL_OPENID20_AUTHENTICATE_IN_BROWSER: Request to perform OpenID 2.0
   *   authentication in browser.
   * @GSASL_VALIDATE_SIMPLE: Request for simple validation.
   * @GSASL_VALIDATE_EXTERNAL: Request for validation of EXTERNAL.
   * @GSASL_VALIDATE_ANONYMOUS: Request for validation of ANONYMOUS.
   * @GSASL_VALIDATE_GSSAPI: Request for validation of GSSAPI/GS2.
   * @GSASL_VALIDATE_SECURID: Reqest for validation of SecurID.
   * @GSASL_VALIDATE_SAML20: Reqest for validation of SAML20.
   * @GSASL_VALIDATE_OPENID20: Reqest for validation of OpenID 2.0 login.
   *
   * Callback/property types.
   */
  typedef enum
  {
    /* Information properties, e.g., username. */
    GSASL_AUTHID = 1,
    GSASL_AUTHZID = 2,
    GSASL_PASSWORD = 3,
    GSASL_ANONYMOUS_TOKEN = 4,
    GSASL_SERVICE = 5,
    GSASL_HOSTNAME = 6,
    GSASL_GSSAPI_DISPLAY_NAME = 7,
    GSASL_PASSCODE = 8,
    GSASL_SUGGESTED_PIN = 9,
    GSASL_PIN = 10,
    GSASL_REALM = 11,
    GSASL_DIGEST_MD5_HASHED_PASSWORD = 12,
    GSASL_QOPS = 13,
    GSASL_QOP = 14,
    GSASL_SCRAM_ITER = 15,
    GSASL_SCRAM_SALT = 16,
    GSASL_SCRAM_SALTED_PASSWORD = 17,
    GSASL_CB_TLS_UNIQUE = 18,
    GSASL_SAML20_IDP_IDENTIFIER = 19,
    GSASL_SAML20_REDIRECT_URL = 20,
    GSASL_OPENID20_REDIRECT_URL = 21,
    GSASL_OPENID20_OUTCOME_DATA = 22,
    /* Client callbacks. */
    GSASL_SAML20_AUTHENTICATE_IN_BROWSER = 250,
    GSASL_OPENID20_AUTHENTICATE_IN_BROWSER = 251,
    /* Server validation callback properties. */
    GSASL_VALIDATE_SIMPLE = 500,
    GSASL_VALIDATE_EXTERNAL = 501,
    GSASL_VALIDATE_ANONYMOUS = 502,
    GSASL_VALIDATE_GSSAPI = 503,
    GSASL_VALIDATE_SECURID = 504,
    GSASL_VALIDATE_SAML20 = 505,
    GSASL_VALIDATE_OPENID20 = 506
  } Gsasl_property;

  /**
   * Gsasl_callback_function:
   * @ctx: libgsasl handle.
   * @sctx: session handle, may be NULL.
   * @prop: enumerated value of Gsasl_property type.
   *
   * Prototype of function that the application should implement.  Use
   * gsasl_callback_set() to inform the library about your callback
   * function.
   *
   * It is called by the SASL library when it need some information
   * from the application.  Depending on the value of @prop, it should
   * either set some property (e.g., username or password) using
   * gsasl_property_set(), or it should extract some properties (e.g.,
   * authentication and authorization identities) using
   * gsasl_property_fast() and use them to make a policy decision,
   * perhaps returning GSASL_AUTHENTICATION_ERROR or GSASL_OK
   * depending on whether the policy permitted the operation.
   *
   * Return value: Any valid return code, the interpretation of which
   *   depend on the @prop value.
   *
   * Since: 0.2.0
   **/
  typedef int (*Gsasl_callback_function) (Gsasl * ctx, Gsasl_session * sctx,
					  Gsasl_property prop);

  /* Library entry and exit points: version.c, init.c, done.c */
  extern GSASL_API int gsasl_init (Gsasl ** ctx);
  extern GSASL_API void gsasl_done (Gsasl * ctx);
  extern GSASL_API const char *gsasl_check_version (const char *req_version);

  /* Callback handling: callback.c */
  extern GSASL_API void gsasl_callback_set (Gsasl * ctx,
					    Gsasl_callback_function cb);
  extern GSASL_API int gsasl_callback (Gsasl * ctx, Gsasl_session * sctx,
				       Gsasl_property prop);

  extern GSASL_API void gsasl_callback_hook_set (Gsasl * ctx, void *hook);
  extern GSASL_API void *gsasl_callback_hook_get (Gsasl * ctx);

  extern GSASL_API void gsasl_session_hook_set (Gsasl_session * sctx,
						void *hook);
  extern GSASL_API void *gsasl_session_hook_get (Gsasl_session * sctx);

  /* Property handling: property.c */
  extern GSASL_API void gsasl_property_set (Gsasl_session * sctx,
					    Gsasl_property prop,
					    const char *data);
  extern GSASL_API void gsasl_property_set_raw (Gsasl_session * sctx,
						Gsasl_property prop,
						const char *data, size_t len);
  extern GSASL_API const char *gsasl_property_get (Gsasl_session * sctx,
						   Gsasl_property prop);
  extern GSASL_API const char *gsasl_property_fast (Gsasl_session * sctx,
						    Gsasl_property prop);

  /* Mechanism handling: listmech.c, supportp.c, suggest.c */
  extern GSASL_API int gsasl_client_mechlist (Gsasl * ctx, char **out);
  extern GSASL_API int gsasl_client_support_p (Gsasl * ctx, const char *name);
  extern GSASL_API const char *gsasl_client_suggest_mechanism (Gsasl * ctx,
							       const char
							       *mechlist);

  extern GSASL_API int gsasl_server_mechlist (Gsasl * ctx, char **out);
  extern GSASL_API int gsasl_server_support_p (Gsasl * ctx, const char *name);

  /* Authentication functions: xstart.c, xstep.c, xfinish.c */
  extern GSASL_API int gsasl_client_start (Gsasl * ctx, const char *mech,
					   Gsasl_session ** sctx);
  extern GSASL_API int gsasl_server_start (Gsasl * ctx, const char *mech,
					   Gsasl_session ** sctx);
  extern GSASL_API int gsasl_step (Gsasl_session * sctx,
				   const char *input, size_t input_len,
				   char **output, size_t * output_len);
  extern GSASL_API int gsasl_step64 (Gsasl_session * sctx,
				     const char *b64input, char **b64output);
  extern GSASL_API void gsasl_finish (Gsasl_session * sctx);

  /* Session functions: xcode.c, mechname.c */
  extern GSASL_API int gsasl_encode (Gsasl_session * sctx,
				     const char *input, size_t input_len,
				     char **output, size_t * output_len);
  extern GSASL_API int gsasl_decode (Gsasl_session * sctx,
				     const char *input, size_t input_len,
				     char **output, size_t * output_len);
  extern GSASL_API const char *gsasl_mechanism_name (Gsasl_session * sctx);

  /* Error handling: error.c */
  extern GSASL_API const char *gsasl_strerror (int err);
  extern GSASL_API const char *gsasl_strerror_name (int err);

  /* Internationalized string processing: stringprep.c */
  extern GSASL_API int gsasl_saslprep (const char *in,
				       Gsasl_saslprep_flags flags, char **out,
				       int *stringpreprc);

  /* Utilities: base64.c, md5pwd.c, crypto.c */
  extern GSASL_API int gsasl_simple_getpass (const char *filename,
					     const char *username,
					     char **key);
  extern GSASL_API int gsasl_base64_to (const char *in, size_t inlen,
					char **out, size_t * outlen);
  extern GSASL_API int gsasl_base64_from (const char *in, size_t inlen,
					  char **out, size_t * outlen);
  extern GSASL_API int gsasl_nonce (char *data, size_t datalen);
  extern GSASL_API int gsasl_random (char *data, size_t datalen);
  extern GSASL_API int gsasl_md5 (const char *in, size_t inlen,
				  char *out[16]);
  extern GSASL_API int gsasl_hmac_md5 (const char *key, size_t keylen,
				       const char *in, size_t inlen,
				       char *outhash[16]);
  extern GSASL_API int gsasl_sha1 (const char *in, size_t inlen,
				   char *out[20]);
  extern GSASL_API int gsasl_hmac_sha1 (const char *key, size_t keylen,
					const char *in, size_t inlen,
					char *outhash[20]);
  extern GSASL_API void gsasl_free (void *ptr);

  /* Get the mechanism API. */
#include "gsasl-mech.h"

#ifndef GSASL_NO_OBSOLETE
  /* For compatibility with earlier versions. */
#include "gsasl-compat.h"
#endif

#ifdef __cplusplus
}
#endif

#endif				/* GSASL_H */
