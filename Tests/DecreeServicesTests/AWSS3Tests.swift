//
//  AWSS3Tests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/21/19.
//

import XCTest
import Decree
@testable import DecreeServices

class AWSS3Tests: XCTestCase {
    let session = TestURLSession()

    #if os(Linux)
    let amzDateKey = "X-Amz-Date"
    let amzContentKey = "X-Amz-Content-Sha256"
    #else
    let amzDateKey = "x-amz-date"
    let amzContentKey = "x-amz-content-sha256"
    #endif

    override func setUp() {
        super.setUp()

        AWS.S3.shared = AWS.S3(
            region: "region",
            bucket: "bucket.name",
            accessKey: "ACCESS",
            secretKey: "SECRET"
        )

        self.session.startedTasks.removeAll()
        AWS.S3.shared.sessionOverride = self.session
    }

    func testGetObject() throws {
        TestableDate.startFakingNow(from: Date(timeIntervalSince1970: -14182980))
        AWS.S3.GetObject(name: "test.txt").makeRequest(callbackQueue: nil) { _ in }

        XCTAssertEqual(self.session.startedTasks.last!.request.url?.absoluteString, "http://bucket.name.s3.amazonaws.com/test.txt")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpMethod, "GET")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpBody, nil)
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?[amzContentKey], "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?[amzDateKey], "19690720T201700Z")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Accept"], "text/xml")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Host"], "bucket.name.s3.amazonaws.com")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Authorization"], "AWS4-HMAC-SHA256 Credential=ACCESS/19690720/region/s3/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=842767d35081b54387252d439593f6af580aeab0a6adb286c02b938979477255")

        TestableDate.startFakingNow(from: Date(timeIntervalSince1970: -14182980))
        XCTAssertEqual(try AWS.S3.GetObject(name: "test.txt").presignURL().absoluteString, "http://bucket.name.s3.amazonaws.com/test.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ACCESS/19690720/region/s3/aws4_request&X-Amz-Date=19690720T201700Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=1911606100195e5b017d24725e716e7f7888872ad0d2ef6df4bb04d6d36f6caa")
    }

    func testGetObjectMetadata() throws {
        TestableDate.startFakingNow(from: Date(timeIntervalSince1970: -14182980))
        AWS.S3.GetObjectMetadata(name: "test.txt").makeRequest(callbackQueue: nil) { _ in }

        XCTAssertEqual(self.session.startedTasks.last!.request.url?.absoluteString, "http://bucket.name.s3.amazonaws.com/test.txt")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpMethod, "HEAD")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpBody, nil)
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?[amzContentKey], "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?[amzDateKey], "19690720T201700Z")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Host"], "bucket.name.s3.amazonaws.com")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Authorization"], "AWS4-HMAC-SHA256 Credential=ACCESS/19690720/region/s3/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=9dd69c90ae5a7949343337c331bbaf56b10e6534b780e1811a443c5b857c1996")

        TestableDate.startFakingNow(from: Date(timeIntervalSince1970: -14182980))
        XCTAssertEqual(try AWS.S3.DeleteObject(name: "test.txt").presignURL().absoluteString, "http://bucket.name.s3.amazonaws.com/test.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ACCESS/19690720/region/s3/aws4_request&X-Amz-Date=19690720T201700Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=8bd1032bd7d7e1e3158b69837ad0e73441eada7a894685ca9318fdf7c3b4409f")
    }

    func testAddObject() {
        TestableDate.startFakingNow(from: Date(timeIntervalSince1970: -14182980))
        let body = "Example Body".data(using: .utf8)!
        AWS.S3.AddObject(name: "test.txt").makeRequest(with: body, callbackQueue: nil) { _ in }

        XCTAssertEqual(self.session.startedTasks.last!.request.url?.absoluteString, "http://bucket.name.s3.amazonaws.com/test.txt")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpMethod, "PUT")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpBody?.string, "Example Body")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?[amzContentKey], "c210a4cca76229ad7bb0a9d2e24fd0440bf24d0f38e2784242a4b10b0fdf826f")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?[amzDateKey], "19690720T201700Z")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Accept"], "text/xml")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Host"], "bucket.name.s3.amazonaws.com")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Authorization"], "AWS4-HMAC-SHA256 Credential=ACCESS/19690720/region/s3/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=fd7cc326c5042e9f0cfc7558dfb12fe3f678c641f4fa1c2d4939d161755d9314")

        TestableDate.startFakingNow(from: Date(timeIntervalSince1970: -14182980))
        XCTAssertEqual(try AWS.S3.AddObject(name: "test.txt").presignURL().absoluteString, "http://bucket.name.s3.amazonaws.com/test.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ACCESS/19690720/region/s3/aws4_request&X-Amz-Date=19690720T201700Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=889713ffd364d22770212a7d7d9cafbf82f04068bd8489a59edc681a595e7d7a")
    }

    func testDeleteObject() throws {
        TestableDate.startFakingNow(from: Date(timeIntervalSince1970: -14182980))
        AWS.S3.DeleteObject(name: "test.txt").makeRequest(callbackQueue: nil) { _ in }

        XCTAssertEqual(self.session.startedTasks.last!.request.url?.absoluteString, "http://bucket.name.s3.amazonaws.com/test.txt")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpMethod, "DELETE")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpBody, nil)
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?[amzContentKey], "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?[amzDateKey], "19690720T201700Z")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Accept"], "text/xml")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Host"], "bucket.name.s3.amazonaws.com")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Authorization"], "AWS4-HMAC-SHA256 Credential=ACCESS/19690720/region/s3/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=fd52d27114132799fd2f57bc1fd9c91b319a189fbfb5c6111bf487bfc5ceb808")

        TestableDate.startFakingNow(from: Date(timeIntervalSince1970: -14182980))
        XCTAssertEqual(try AWS.S3.DeleteObject(name: "test.txt").presignURL().absoluteString, "http://bucket.name.s3.amazonaws.com/test.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ACCESS/19690720/region/s3/aws4_request&X-Amz-Date=19690720T201700Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=8bd1032bd7d7e1e3158b69837ad0e73441eada7a894685ca9318fdf7c3b4409f")
    }

    func testMocking() {
        let mock = AWS.S3.shared.startMocking()

        mock.expectPresigning(AWS.S3.GetObject(name: "test.txt"), returning: URL(string: "http://example.com")!)
        XCTAssertEqual(try AWS.S3.GetObject(name: "test.txt").presignURL().absoluteString, "http://example.com")

        mock.expectPresigning(AWS.S3.GetObject(name: "other.txt"), returning: URL(string: "http://example.com")!)
        XCTAssertThrowsError(try AWS.S3.GetObject(name: "test.txt").presignURL(), "", { error in
            XCTAssertEqual((error as? DecreeError)?.debugDescription, """
                Error making request: A request was made to the wrong path of ‘GetObject’.
                Path was ‘/test.txt’ but expected ‘/other.txt‘.
                """
            )
        })

        mock.expectPresigning(AWS.S3.DeleteObject(name: "other.txt"), returning: URL(string: "http://example.com")!)
        XCTAssertThrowsError(try AWS.S3.GetObject(name: "test.txt").presignURL(), "", { error in
            XCTAssertEqual((error as? DecreeError)?.debugDescription, """
                Error making request: A request was made to ‘GetObject’ when ‘DeleteObject’ was expected.
                """
            )
        })

    }
}
