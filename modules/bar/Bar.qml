import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../services" as Services

PanelWindow {
    id: panel
    color: "transparent"  // Make panel background transparent

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 30  // PANEL HEIGHT

    margins {
        top: 2
        left: 2
        right: 2
    }

        Rectangle {
            id: bar
            anchors.fill: parent
            color: "#40000000"
            //opacity: 0.9  // opacity works even on the border, so better use the hex code for this
            radius: 11
            border.color: "#00bee7"
            border.width: 2

            Row {
                id: workspacesRow   // | 1 | 2 | 3 | 4

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 16
                }
                spacing: 5  // Space between workspace buttons

                Repeater {
                        model: Hyprland.workspaces

                        Rectangle {
                         width: 35
                         height: 22
                         radius: 10
                         color: modelData.active ? "#00bee7" : "#333333"
                         border.color: modelData.active ? "#00d6d8" : "#575757"
                         border.width: 1


                         MouseArea {
                            anchors.fill: parent
                            onClicked: Hyprland.dispatch("workspace " + modelData.id)
                         }

                         Text {
                            text: modelData.id
                            anchors.centerIn: parent
                            color: modelData.active ? "#000000" : "#cccccc"
                            font.pixelSize: 14
                            font.bold: modelData.active
                            font.family: "JetBrains Mono Nerd Font, sans-serif"
                         }
                        }                         
                } 

                Text {
                    visible: Hyprland.workspaces.length === 0
                    text: "No workspaces"
                    color: "#cccccc"
                    font.pixelSize: 12
                    font.family: "JetBrains Mono Nerd Font, sans-serif"
                }
            }

            Text {
                id: windowTitle
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                
                text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "Desktop"
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 14
                font.family: "JetBrains Mono Nerd Font, sans-serif"
                
                // Limit text width to avoid overlap with other elements
                width: Math.min(implicitWidth, parent.width - 300)
                elide: Text.ElideRight
            }

            Text {
                id: audioWidget
                text: {
                    if (!Services.Audio.ready || !Services.Audio.sink?.audio) return "🔇 --"
                    
                    var volume = Math.round(Services.Audio.sink.audio.volume * 100)
                    var muted = Services.Audio.sink.audio.muted
                    
                    var icon = muted ? "🔇" : 
                               volume === 0 ? "🔇" :
                               volume < 30 ? "🔈" :
                               volume < 70 ? "🔉" : "🔊"
                    
                    return icon + " " + (muted ? "MUTE" : volume + "%")
                }
                color: Services.Audio.sink?.audio?.muted ? "#ff6b6b" : "#ffffff"
                font.pixelSize: 14
                font.family: "JetBrains Mono Nerd Font, sans-serif"
                anchors {
                    right: timeDisplay.left
                    verticalCenter: parent.verticalCenter
                    rightMargin: 20
                }
            }

            Text {
                id: cliphistWidget
                text: "📋 " + (Services.Cliphist.entries.length > 0 ? Services.Cliphist.entries.length : "0")
                color: "#ffffff"
                font.pixelSize: 14
                font.family: "JetBrains Mono Nerd Font, sans-serif"
                anchors {
                    right: audioWidget.left
                    verticalCenter: parent.verticalCenter
                    rightMargin: 20
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // Hier könnte später ein Popup oder Menü geöffnet werden
                        console.log("Cliphist clicked - " + Services.Cliphist.entries.length + " entries")
                        Services.Cliphist.refresh()
                    }
                }
                
                // Tooltip-ähnlicher Hover-Effekt
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#5ef5f7"
                    onExited: parent.color = "#ffffff"
                    onClicked: {
                        console.log("Cliphist clicked - " + Services.Cliphist.entries.length + " entries")
                        Services.Cliphist.refresh()
                    }
                }
            }

            Text {
                id: timeDisplay
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: 16
                }
                
                property string currentTime: ""
                
                text: currentTime
                textFormat: Text.RichText
                color: "#ffffff"
                font.pixelSize: 14
                font.family: "JetBrains Mono Nerd Font, sans-serif"

                // Update time every second
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        var now = new Date()
                        var dayNames = ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"]
                        var monthNames = ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]
                        var dayName = dayNames[now.getDay()]
                        var monthName = monthNames[now.getMonth()]
                        var day = now.getDate()
                        var dateStr = dayName + " " + day + ". " + monthName
                        var timeStr = Qt.formatTime(now, "hh:mm:ss")
                        // Replace colons with colored, non-bold colons
                        var formattedTime = timeStr.replace(/:/g, '</b><span style="color:#5ef5f7">:</span><b>')
                        timeDisplay.currentTime = dateStr + " • <b>" + formattedTime + "</b>"
                    }
                }

                // Initialize time immediately
                Component.onCompleted: {
                    var now = new Date()
                    var dayNames = ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"]
                    var monthNames = ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]
                    var dayName = dayNames[now.getDay()]
                    var monthName = monthNames[now.getMonth()]
                    var day = now.getDate()
                    var dateStr = dayName + " " + day + ". " + monthName
                    var timeStr = Qt.formatTime(now, "hh:mm:ss")
                    // Replace colons with colored, non-bold colons
                    var formattedTime = timeStr.replace(/:/g, '<span style="color:#5ef5f7">:</span><b>')
                    currentTime = dateStr + " • <b>" + formattedTime + "</b>"
                }
            }
        }
}


