//
//  OpenSSLHelper.h
//  Utils
//
//  Copyright © 2016 SAP SE or an SAP affiliate company. All rights reserved.
//
//  No part of this publication may be reproduced or transmitted in any form or for any purpose
//  without the express permission of SAP SE.  The information contained herein may be changed
//  without prior notice.
//

#ifndef OpenSSLHelper_h
#define OpenSSLHelper_h

#include "openssl/bio.h"

void initializeOpenSSL();
BIO* createCSR(const unsigned char* data, long dataLength, const char* subject, char* keyUsage, char* basicConstraints, char* extKeyUsages, char* subjectAltNames);
BIO* createPKCS12(const unsigned char* privateKeyData, long privateKeyDataLength, const unsigned char* certificateDataData, long certificateDataLength);
BIO* createX509CertificateData(const unsigned char* data, long dataLength);

#endif /* OpenSSLHelper_h */
