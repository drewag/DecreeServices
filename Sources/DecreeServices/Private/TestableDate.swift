//
//  TestableDate.swift
//  DecreeServices
//
//  Created by Andrew J Wagner on 7/24/19.
//

import Foundation

struct TestableDate {
    private static var faked: (base: Date, started: Date)?

    static func startFakingNow(from: Date) {
        faked = (from, Date())
    }

    static func stopFakingNow() {
        faked = nil
    }

    static func addFake(interval: TimeInterval) {
        if faked == nil {
            self.startFakingNow(from: Date())
        }
        if let old = faked {
            faked = (old.base.addingTimeInterval(interval), started: old.started)
        }
    }

    static var now: Date {
        guard let faked = faked else {
            return Date()
        }
        let interval = Date().timeIntervalSince(faked.started)
        return faked.base.addingTimeInterval(interval)
    }
}
