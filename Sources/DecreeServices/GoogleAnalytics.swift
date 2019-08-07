//
//  GoogleAnalytics.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import Foundation
import Decree

public struct Google {
    /// Google Analytics Web Service
    ///
    /// Google Analytics Measurement Protocol
    /// https://developers.google.com/analytics/devguides/collection/protocol/v1/reference
    public struct Analytics: WebService {
        public typealias BasicResponse = NoBasicResponse
        public typealias ErrorResponse = NoErrorResponse

        public static var shared = Analytics()

        public var sessionOverride: Session?

        /// Customize the tracking ID for this instance of the service
        public var trackingId = "UA-000000000-0"

        public let baseURL = URL(string: "https://www.google-analytics.com")!
    }
}

extension Google.Analytics {
    /// Collect data e.g. record a page view
    public struct Collect: InEndpoint {
        public typealias Service = Google.Analytics

        public static let method = Method.post
        public let path = "collect"

        public typealias Input = Record

        public init() {}

        public static let inputFormat = InputFormat.formURLEncoded
    }

    public struct Record: Encodable {
        public enum Kind {
            /// Page view
            case pageView(endpoint: String)
        }

        public let v = "1"
        public let tid: String
        public let cid: String
        public let ds = "api"
        public let t: String
        public let dp: String?
        public let uip: String?
        public let cd1: String?
        public let cd2: String?
        public let cd3: String?

        /// Define data to be recorded
        ///
        /// - Parameters:
        ///     - kind: The kind of data to record
        ///     - trackingId: Override the tracking id on the shared instance
        ///     - ipAddress: IP Address that is the source of the record
        ///     - clientId: A unique identifier for the source of the record
        ///     - customField1: Custom data field
        ///     - customField2: Custom data field
        ///     - customField3: Custom data field
        public init(
            kind: Kind,
            trackingId: String = Google.Analytics.shared.trackingId,
            ipAddress: String? = nil,
            clientId: String = UUID().uuidString,
            customField1: String? = nil,
            customField2: String? = nil,
            customField3: String? = nil
            )
        {
            self.tid = trackingId
            self.cid = clientId

            switch kind {
            case .pageView(let endpoint):
                self.t = "pageview"
                self.dp = endpoint
            }

            self.uip = ipAddress
            self.cd1 = customField1
            self.cd2 = customField2
            self.cd3 = customField3
        }
    }

}
