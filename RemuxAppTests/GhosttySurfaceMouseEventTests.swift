import XCTest
import CoreGraphics
import GhosttyKit
@testable import Remux

final class GhosttySurfaceMouseEventTests: XCTestCase {
    func testMouseButtonEventPreservesCValues() {
        let event = GhosttySurfaceMouseButtonEvent(
            state: .press,
            button: .right,
            mods: [.alt, .ctrl]
        )

        event.withCValues { state, button, mods in
            XCTAssertEqual(state, GHOSTTY_MOUSE_PRESS)
            XCTAssertEqual(button, GHOSTTY_MOUSE_RIGHT)
            XCTAssertEqual(mods.rawValue, GhosttySurfaceKeyEvent.Mods([.alt, .ctrl]).rawValue)
        }
    }

    func testMouseScrollModsEncodePrecisionAndMomentum() {
        let mods = GhosttySurfaceMouseScrollMods(
            precision: true,
            momentum: .changed
        )

        XCTAssertTrue(mods.precision)
        XCTAssertEqual(mods.momentum, .changed)
        XCTAssertEqual(mods.rawValue, 0b0000_0111)
    }

    func testMouseScrollModsRoundTripRawValue() {
        let mods = GhosttySurfaceMouseScrollMods(rawValue: 0b0000_1001)

        XCTAssertTrue(mods.precision)
        XCTAssertEqual(mods.momentum, .ended)
    }

    func testTapGestureActivatesInputOnlyWhenMouseIsNotCaptured() {
        XCTAssertEqual(
            GhosttySurfaceTapGesture.actions(
                forLocalPoint: CGPoint(x: 10, y: 20),
                mouseCaptured: false
            ),
            [.activateInput(.terminalKeyboard)]
        )
    }

    func testTapGestureActivatesInputAndEmitsMouseClickWhenMouseIsCaptured() {
        let point = CGPoint(x: 10, y: 20)

        XCTAssertEqual(
            GhosttySurfaceTapGesture.actions(
                forLocalPoint: point,
                mouseCaptured: true
            ),
            [
                .activateInput(.terminalKeyboard),
                .mousePosition(point),
                .mouseButton(.init(state: .press, button: .left)),
                .mouseButton(.init(state: .release, button: .left)),
            ]
        )
    }

    func testClaudeTapNearCursorRowOpensComposer() {
        let cursor = CGRect(x: 40, y: 200, width: 8, height: 16)

        for y in [CGFloat(205), 168, 247] {
            XCTAssertEqual(
                GhosttySurfaceTapGesture.input(
                    forLocalPoint: CGPoint(x: 300, y: y),
                    agent: .claudeCode,
                    cursorFrame: cursor
                ),
                .composer,
                "y=\(y)"
            )
        }
    }

    func testClaudeTapAwayFromCursorRowRaisesNoKeyboard() {
        let cursor = CGRect(x: 40, y: 200, width: 8, height: 16)

        for y in [CGFloat(167), 248, 20] {
            XCTAssertEqual(
                GhosttySurfaceTapGesture.input(
                    forLocalPoint: CGPoint(x: 44, y: y),
                    agent: .claudeCode,
                    cursorFrame: cursor
                ),
                .focus,
                "y=\(y)"
            )
        }
    }

    func testClaudeTapWithoutCursorRaisesNoKeyboard() {
        XCTAssertEqual(
            GhosttySurfaceTapGesture.input(
                forLocalPoint: CGPoint(x: 10, y: 20),
                agent: .claudeCode,
                cursorFrame: nil
            ),
            .focus
        )
    }

    func testNonAgentTapRaisesTerminalKeyboardAnywhere() {
        XCTAssertEqual(
            GhosttySurfaceTapGesture.input(
                forLocalPoint: CGPoint(x: 10, y: 600),
                agent: nil,
                cursorFrame: CGRect(x: 40, y: 200, width: 8, height: 16)
            ),
            .terminalKeyboard
        )
    }

    func testClaudeTapAwayFromCursorStillForwardsCapturedMouseClick() {
        let point = CGPoint(x: 10, y: 20)

        XCTAssertEqual(
            GhosttySurfaceTapGesture.actions(
                forLocalPoint: point,
                mouseCaptured: true,
                agent: .claudeCode,
                cursorFrame: CGRect(x: 40, y: 200, width: 8, height: 16)
            ),
            [
                .activateInput(.focus),
                .mousePosition(point),
                .mouseButton(.init(state: .press, button: .left)),
                .mouseButton(.init(state: .release, button: .left)),
            ]
        )
    }

}
