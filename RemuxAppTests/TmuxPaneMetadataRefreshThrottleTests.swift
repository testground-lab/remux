import XCTest
@testable import Remux

final class TmuxPaneMetadataRefreshThrottleTests: XCTestCase {
    func testFirstRequestPerWindowSendsImmediately() {
        var throttle = TmuxPaneMetadataRefreshThrottle()

        XCTAssertEqual(throttle.request(0, now: 10), .send)
        XCTAssertEqual(throttle.request(1, now: 10), .send)
    }

    func testRequestInsideIntervalIsDeferredToItsEndAndLaterOnesCoalesce() {
        var throttle = TmuxPaneMetadataRefreshThrottle()
        XCTAssertEqual(throttle.request(0, now: 10), .send)

        guard case .sendAfter(let delay) = throttle.request(0, now: 10.25) else {
            return XCTFail("expected a deferred refresh")
        }
        XCTAssertEqual(delay, 0.75, accuracy: 0.0001)
        XCTAssertEqual(throttle.request(0, now: 10.5), .coalesced)

        throttle.sendDeferred(0, now: 11)
        guard case .sendAfter = throttle.request(0, now: 11.5) else {
            return XCTFail("the deferred send must restart the interval")
        }
    }

    func testRequestAfterIntervalSendsImmediately() {
        var throttle = TmuxPaneMetadataRefreshThrottle()
        XCTAssertEqual(throttle.request(0, now: 10), .send)

        XCTAssertEqual(
            throttle.request(0, now: 10 + TmuxPaneMetadataRefreshThrottle.interval),
            .send
        )
    }
}
