//
//  OpenSSLHelperProxy.h
//  Utils
//
//  Copyright © 2016 SAP SE or an SAP affiliate company. All rights reserved.
//
//  No part of this publication may be reproduced or transmitted in any form or for any purpose
//  without the express permission of SAP SE.  The information contained herein may be changed
//  without prior notice.
//

@interface OpenSSLHelperProxy : NSObject

@property (class, strong, nonatomic) OpenSSLHelperProxy* _Nonnull shared;

-(NSData* _Nullable)createCertificateSigningRequestDataUsingPrivateKeyData:(NSData* _Nonnull)privateKeyData subject:(NSString* _Nonnull)subject keyUsage:(NSString* _Nullable)keyUsage basicConstraints:(NSString* _Nullable)basicConstraints extKeyUsages:(NSString* _Nullable)extKeyUsages subjectAltNames:(NSString* _Nullable)subjectAltNames;
-(NSData* _Nullable)PKCS12FromPrivateKeyData:(NSData* _Nonnull)privateKeyData X509CertificateData:(NSData* _Nonnull)X509CertificateData;
-(NSData* _Nullable)X509CertificateDataFromPKCS7Data:(NSData* _Nonnull)data;

@end
