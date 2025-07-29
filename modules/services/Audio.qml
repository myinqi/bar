import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
pragma Singleton
pragma ComponentBehavior: Bound

/**
 * A nice wrapper for default Pipewire audio sink and source.
 */
Singleton {
    id: root

    property bool ready: Pipewire.defaultAudioSink?.ready ?? false
    property PwNode sink: Pipewire.defaultAudioSink
    property PwNode source: Pipewire.defaultAudioSource

    signal sinkProtectionTriggered(string reason);

    PwObjectTracker {
        objects: [sink, source]
    }

    // Simplified audio protection - can be extended later
    Connections {
        target: sink?.audio ?? null
        property real lastVolume: 0
        function onVolumeChanged() {
            if (sink.ready && (isNaN(sink.audio.volume) || sink.audio.volume === undefined || sink.audio.volume === null)) {
                sink.audio.volume = 0;
            }
            lastVolume = sink.audio.volume;
        }
    }

}
