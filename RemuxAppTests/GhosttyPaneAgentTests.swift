import XCTest
@testable import Remux

final class GhosttyPaneAgentTests: XCTestCase {
    func testRecognizesClaudeCodeByNameAndVersionShapedBinary() {
        for command in ["claude", "2.1.303", "2.2.0", "10.0"] {
            XCTAssertEqual(GhosttyPaneAgent(currentCommand: command), .claudeCode, command)
        }
    }

    func testIgnoresOtherCommands() {
        for command in ["zsh", "node", "vim", "", "2", "2.", ".2", "2.1a", "v2.1.0", "claude-code"] {
            XCTAssertNil(GhosttyPaneAgent(currentCommand: command), command)
        }
    }
}
