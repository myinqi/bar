pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property list<string> entries: []
    
    function fuzzyQuery(search: string): var {
        // Simple search implementation
        return entries.filter(entry => 
            entry.toLowerCase().includes(search.toLowerCase())
        ).slice(0, 50)
    }

    function refresh() {
        readProc.buffer = []
        readProc.running = true
    }

    function copy(entry) {
        // Simplified copy function
        Quickshell.execDetached(["bash", "-c", "echo '" + entry + "' | cliphist decode | wl-copy"]);
    }

    function deleteEntry(entry) {
        // Simplified delete function
        Quickshell.execDetached(["bash", "-c", "echo '" + entry + "' | cliphist delete"]);
        root.refresh();
    }

    Connections {
        target: Quickshell
        function onClipboardTextChanged() {
            delayedUpdateTimer.restart()
        }
    }

    Timer {
        id: delayedUpdateTimer
        interval: 500  // 500ms delay
        repeat: false
        onTriggered: {
            root.refresh()
        }
    }

    Process {
        id: readProc
        property list<string> buffer: []
        
        command: ["cliphist", "list"]

        stdout: SplitParser {
            onRead: (line) => {
                readProc.buffer.push(line)
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.entries = readProc.buffer
            } else {
                console.error("[Cliphist] Failed to refresh with code", exitCode, "and status", exitStatus)
            }
        }
    }
}
