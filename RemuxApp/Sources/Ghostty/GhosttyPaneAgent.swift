import Foundation

/// Recognizes coding agents from the command tmux reports for a pane.
enum GhosttyPaneAgent {
    /// Claude Code's native installer names its binary after the release, so
    /// tmux reports a version such as `2.1.303` that changes on every update.
    static func isClaudeCode(_ currentCommand: String) -> Bool {
        currentCommand == "claude"
            || currentCommand.wholeMatch(of: #/[0-9]+(\.[0-9]+)+/#) != nil
    }
}
