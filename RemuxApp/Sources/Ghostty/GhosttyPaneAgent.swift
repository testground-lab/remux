import Foundation

/// A coding agent recognized from the command tmux reports for a pane.
enum GhosttyPaneAgent: Equatable {
    case claudeCode

    init?(currentCommand: String) {
        if Self.isClaudeCode(currentCommand) {
            self = .claudeCode
        } else {
            return nil
        }
    }

    /// Claude Code's native installer names its binary after the release, so
    /// tmux reports a version such as `2.1.303` that changes on every update.
    private static func isClaudeCode(_ command: String) -> Bool {
        command == "claude" || command.wholeMatch(of: #/\d+(\.\d+)+/#) != nil
    }
}
