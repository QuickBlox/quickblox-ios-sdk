/* internal.h --- Internal header with hidden library handle structures.
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

#ifndef INTERNAL_H
#define INTERNAL_H

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

/* Get specifications. */
#include "gsasl.h"

/* Get malloc, free, ... */
#include <stdlib.h>

/* Get strlen, strcpy, ... */
#include <string.h>

/* Main library handle. */
struct Gsasl
{
  size_t n_client_mechs;
  Gsasl_mechanism *client_mechs;
  size_t n_server_mechs;
  Gsasl_mechanism *server_mechs;
  /* Callback. */
  Gsasl_callback_function cb;
  void *application_hook;
#ifndef GSASL_NO_OBSOLETE
  /* Obsolete stuff. */
  Gsasl_client_callback_authorization_id cbc_authorization_id;
  Gsasl_client_callback_authentication_id cbc_authentication_id;
  Gsasl_client_callback_password cbc_password;
  Gsasl_client_callback_passcode cbc_passcode;
  Gsasl_client_callback_pin cbc_pin;
  Gsasl_client_callback_anonymous cbc_anonymous;
  Gsasl_client_callback_qop cbc_qop;
  Gsasl_client_callback_maxbuf cbc_maxbuf;
  Gsasl_client_callback_service cbc_service;
  Gsasl_client_callback_realm cbc_realm;
  Gsasl_server_callback_validate cbs_validate;
  Gsasl_server_callback_securid cbs_securid;
  Gsasl_server_callback_retrieve cbs_retrieve;
  Gsasl_server_callback_cram_md5 cbs_cram_md5;
  Gsasl_server_callback_digest_md5 cbs_digest_md5;
  Gsasl_server_callback_external cbs_external;
  Gsasl_server_callback_anonymous cbs_anonymous;
  Gsasl_server_callback_realm cbs_realm;
  Gsasl_server_callback_qop cbs_qop;
  Gsasl_server_callback_maxbuf cbs_maxbuf;
  Gsasl_server_callback_cipher cbs_cipher;
  Gsasl_server_callback_service cbs_service;
  Gsasl_server_callback_gssapi cbs_gssapi;
#endif
};

/* Per-session library handle. */
struct Gsasl_session
{
  Gsasl *ctx;
  int clientp;
  Gsasl_mechanism *mech;
  void *mech_data;
  void *application_hook;

  /* Properties. */
  char *anonymous_token;
  char *authid;
  char *authzid;
  char *password;
  char *passcode;
  char *pin;
  char *suggestedpin;
  char *service;
  char *hostname;
  char *gssapi_display_name;
  char *realm;
  char *digest_md5_hashed_password;
  char *qops;
  char *qop;
  char *scram_iter;
  char *scram_salt;
  char *scram_salted_password;
  char *cb_tls_unique;
  char *saml20_idp_identifier;
  char *saml20_redirect_url;
  char *openid20_redirect_url;
  char *openid20_outcome_data;
  /* If you add anything here, remember to change change
     gsasl_finish() in xfinish.c and map() in property.c.  */

#ifndef GSASL_NO_OBSOLETE
  /* Obsolete stuff. */
  void *application_data;
#endif
};

#ifndef GSASL_NO_OBSOLETE
const char *_gsasl_obsolete_property_map (Gsasl_session * sctx,
					  Gsasl_property prop);
int _gsasl_obsolete_callback (Gsasl * ctx, Gsasl_session * sctx,
			      Gsasl_property prop);
#endif

#endif /* INTERNAL_H */
