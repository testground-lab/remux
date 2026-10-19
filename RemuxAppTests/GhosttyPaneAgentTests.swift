import XCTest
@testable import Remux

final class GhosttyPaneAgentTests: XCTestCase {
    func testRecognizesClaudeCodeByNameAndVersionShapedBinary() {
        for command in ["claude", "2.1.303", "2.2.0", "10.0"] {
            XCTAssertTrue(GhosttyPaneAgent.isClaudeCode(command), command)
        }
    }

    func testIgnoresOtherCommands() {
        for command in ["zsh", "node", "vim", "", "2", "2.", ".2", "2.1a", "v2.1.0", "claude-code", "٢.١"] {
            XCTAssertFalse(GhosttyPaneAgent.isClaudeCode(command), command)
        }
    }
}
