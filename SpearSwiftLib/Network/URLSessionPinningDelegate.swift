//
//  URLSessionPinningDelegate.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 12/1/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import Foundation

final class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
    private let certificate: Data

    init(certificate: Data) {
        self.certificate = certificate
    }

    func urlSession(_: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let failed = { completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil) }

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust else {
            failed()
            return
        }

        var secresult = SecTrustResultType.invalid
        let status = SecTrustEvaluate(serverTrust, &secresult)

        if errSecSuccess != status {
            failed()
            return
        }

        guard let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            failed()
            return
        }

        let serverCertData = SecCertificateCopyData(serverCertificate)
        guard let data = CFDataGetBytePtr(serverCertData) else {
            failed()
            return
        }
        let size = CFDataGetLength(serverCertData)
        let cert1 = Data(bytes: data, count: size)

        if cert1 == certificate {
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
        } else {
            failed()
        }
    }
}
