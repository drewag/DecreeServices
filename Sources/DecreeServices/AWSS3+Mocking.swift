//
//  AWSS3+Mocking.swift
//  DecreeServices
//
//  Created by Andrew J Wagner on 8/7/19.
//

import Foundation
import Decree

extension WebServiceMock where S == AWS.S3 {
    public func expectPresigning<E: AWSS3Endpoint>(_ endpoint: E, returning: URL) {
        self.add(PresignExpectation<E>(path: endpoint.path, returning: returning))
    }
}


class PresignExpectation<E: AWSS3Endpoint>: AnyExpectation {
    static var typeName: String {
        return "\(E.self)"
    }

    let path: String
    let returning: URL

    init(path: String, returning: URL) {
        self.path = path
        self.returning = returning
    }
}
