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

    let pathValidation: PathValidation
    let returning: URL
    var waiting = DispatchSemaphore(value: 0)

    init(pathValidation: @escaping PathValidation, returning: URL) {
        self.pathValidation = pathValidation
        self.returning = returning
    }

    convenience init(path: String, returning: URL) {
        self.init(
            pathValidation: { actual in
                guard actual == path else {
                    throw DecreeError(.incorrectExpectationPath(
                        expected: path,
                        actual: actual,
                        endpoint: String(describing: E.self)),
                        operationName: E.operationName
                    )
                }
            },
            returning: returning
        )
    }
}
