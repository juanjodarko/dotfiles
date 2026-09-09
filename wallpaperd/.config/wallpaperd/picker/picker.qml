// wallpaperd picker — a standalone, one-shot Quickshell wallpaper chooser, in the
// Omarchy coverflow style: a horizontal carousel where the selected wallpaper is
// expanded and in full colour, and the neighbours are skewed slices in greyscale.
// Only the nearby items load their image (lazy), so a huge library stays light.
//
// Launched by `wallpaperd pick`. Rows come from $WALLPAPERD_PICK_ROWS_FILE (one
// "image[\tthumbnail]" per line). Left/Right move, typing filters, Enter/click
// sets (writes the path to $WALLPAPERD_PICK_SELECTION_FILE and quits), Esc cancels.
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "ImagePickerModel.js" as Model

Scope {
    id: app

    readonly property string rowsFile: Quickshell.env("WALLPAPERD_PICK_ROWS_FILE") || ""
    readonly property string selectionFile: Quickshell.env("WALLPAPERD_PICK_SELECTION_FILE") || ""
    readonly property string currentWp: Quickshell.env("WALLPAPERD_PICK_CURRENT") || ""

    // Catppuccin Frappe (matches DockShell's default palette).
    readonly property var pal: ({
        bg: "#232634", surface: "#414559", overlay: "#737994",
        fg: "#c6d0f5", muted: "#a5adce", accent: "#ca9ee6"
    })
    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    // coverflow geometry (from Omarchy)
    readonly property int expandedW: 768
    readonly property int expandedH: 475
    readonly property int sliceW: 108
    readonly property int sliceH: 432
    readonly property int sliceSpacing: -30
    readonly property int skew: 28
    readonly property int nearby: 16
    readonly property real itemStep: sliceW + sliceSpacing

    property var images: []
    property string filterText: ""
    readonly property var filtered: {
        if (!filterText) return images
        var out = []
        for (var i = 0; i < images.length; i++) if (Model.itemMatches(images, i, filterText)) out.push(images[i])
        return out
    }
    property int sel: 0
    onFilteredChanged: if (sel >= filtered.length) sel = Math.max(0, filtered.length - 1)

    function move(d) { sel = Math.max(0, Math.min(filtered.length - 1, sel + d)) }
    function commit() {
        if (sel >= 0 && sel < filtered.length && selectionFile !== "")
            selWriter.setText(filtered[sel].filePath + "\n")
        Qt.quit()
    }
    function cancel() { Qt.quit() }
    function typeChar(c) { filterText += c; sel = 0 }
    function backspace() { filterText = filterText.slice(0, -1); sel = 0 }

    FileView { id: selWriter; path: app.selectionFile; atomicWrites: true; printErrors: false }
    FileView {
        path: app.rowsFile
        onLoaded: {
            app.images = Model.loadRows(text())
            app.sel = app.currentWp ? Math.max(0, Model.indexForSelectedImage(app.images, app.currentWp)) : 0
        }
    }

    // ---- lazy thumbnail generation (only for what you browse near) ----
    property var thumbQueue: []            // plain array of {image, thumb}
    property var thumbInProgress: ({})     // thumb -> true (plain object)
    property string lastDoneThumb: ""      // reactive: cells reload when their thumb lands
    readonly property int workerCount: 3

    function requestThumb(image, thumb) {
        if (!thumb || thumb === image) return
        if (thumbInProgress[thumb]) return
        for (var i = 0; i < thumbQueue.length; i++) if (thumbQueue[i].thumb === thumb) return
        thumbQueue.push({ image: image, thumb: thumb })
        pumpWorkers()
    }
    function pumpWorkers() {
        for (var i = 0; i < workers.count; i++) { var w = workers.objectAt(i); if (w) w.take() }
    }

    Instantiator {
        id: workers
        model: app.workerCount
        delegate: Process {
            id: wk
            property string curThumb: ""
            function take() {
                if (running || app.thumbQueue.length === 0) return
                var job = app.thumbQueue.shift()
                curThumb = job.thumb
                app.thumbInProgress[job.thumb] = true
                command = ["vipsthumbnail", job.image, "--size", "960x960", "-o", job.thumb + "[Q=82,strip]"]
                running = true
            }
            onExited: {
                delete app.thumbInProgress[curThumb]
                app.lastDoneThumb = curThumb   // notify the waiting cell
                curThumb = ""
                take()
            }
        }
    }

    PanelWindow {
        id: win
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "wallpaperd-picker"
        WlrLayershell.layer: WlrLayer.Overlay
        color: "transparent"

        property bool focusPrimed: false
        WlrLayershell.keyboardFocus: focusPrimed ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.Exclusive
        Timer { id: prime; interval: 75; onTriggered: win.focusPrimed = true }
        Component.onCompleted: prime.restart()

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0.055, 0.06, 0.078, 0.94)      // near-opaque backdrop
            MouseArea { anchors.fill: parent; onClicked: app.cancel() }
        }

        FocusScope {
            anchors.fill: parent
            focus: true
            Keys.onPressed: (e) => {
                if (e.key === Qt.Key_Escape) { if (app.filterText) app.filterText = ""; else app.cancel(); e.accepted = true }
                else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { app.commit(); e.accepted = true }
                else if (e.key === Qt.Key_Left || e.key === Qt.Key_Backtab) { app.move(-1); e.accepted = true }
                else if (e.key === Qt.Key_Right || (e.key === Qt.Key_Tab)) { app.move(1); e.accepted = true }
                else if (e.key === Qt.Key_Backspace) { app.backspace(); e.accepted = true }
                else if (e.text && e.text.length === 1 && e.text.charCodeAt(0) >= 32 && e.text.charCodeAt(0) !== 127) { app.typeChar(e.text); e.accepted = true }
            }

            // header
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.topMargin: 40
                text: "󰸉  " + (app.filtered.length) + " / " + app.images.length + "     ←→ browse   ·   type to filter   ·   ↵ set   ·   esc cancel"
                color: app.pal.muted; font.family: app.fontFamily; font.pixelSize: 13
            }

            // carousel
            Item {
                id: carousel
                anchors.centerIn: parent
                width: app.expandedW + 13 * app.itemStep
                height: app.expandedH + 60
                readonly property real previewX: (width - app.expandedW) / 2

                Repeater {
                    model: app.filtered
                    delegate: Item {
                        id: cell
                        required property var modelData
                        required property int index
                        readonly property int rel: index - app.sel
                        readonly property bool selected: rel === 0
                        readonly property bool near: Math.abs(rel) <= app.nearby
                        property bool activated: near
                        onNearChanged: if (near) activated = true

                        visible: near
                        width: selected ? app.expandedW : app.sliceW
                        height: selected ? app.expandedH : app.sliceH
                        y: (carousel.height - height) / 2 - 10
                        x: selected ? carousel.previewX
                           : (rel < 0 ? carousel.previewX + rel * app.itemStep
                                      : carousel.previewX + app.expandedW + app.sliceSpacing + (rel - 1) * app.itemStep)
                        z: selected ? 100 : 50 - Math.min(Math.abs(rel), 40)
                        Behavior on x { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }
                        Behavior on width { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }
                        Behavior on height { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }

                        // parallelogram corners (skew)
                        readonly property real skAbs: Math.abs(app.skew)
                        readonly property real topLeft: app.skew >= 0 ? skAbs : 0
                        readonly property real topRight: app.skew >= 0 ? width : width - skAbs
                        readonly property real bottomRight: app.skew >= 0 ? width - skAbs : width
                        readonly property real bottomLeft: app.skew >= 0 ? 0 : skAbs

                        Loader {
                            anchors.fill: parent
                            active: cell.activated
                            sourceComponent: Item {
                                anchors.fill: parent

                                // parallelogram mask
                                Item {
                                    id: maskShape
                                    anchors.fill: parent
                                    visible: false
                                    layer.enabled: true
                                    Shape {
                                        anchors.fill: parent
                                        antialiasing: true
                                        preferredRendererType: Shape.CurveRenderer
                                        ShapePath {
                                            fillColor: "white"; strokeColor: "transparent"
                                            startX: cell.topLeft; startY: 0
                                            PathLine { x: cell.topRight; y: 0 }
                                            PathLine { x: cell.bottomRight; y: cell.height }
                                            PathLine { x: cell.bottomLeft; y: cell.height }
                                            PathLine { x: cell.topLeft; y: 0 }
                                        }
                                    }
                                }

                                // image, masked to the parallelogram + greyscale unless selected
                                Item {
                                    anchors.fill: parent
                                    layer.enabled: true
                                    layer.smooth: true
                                    layer.effect: MultiEffect {
                                        maskEnabled: true
                                        maskSource: maskShape
                                        maskThresholdMin: 0.3
                                        maskSpreadAtMin: 0.3
                                        // greyscale → full colour animates in over ~1s when this
                                        // wallpaper becomes the selected one.
                                        saturation: cell.selected ? 0.0 : -1.0
                                        brightness: cell.selected ? 0.0 : -0.06
                                        Behavior on saturation { NumberAnimation { duration: 950; easing.type: Easing.OutCubic } }
                                        Behavior on brightness { NumberAnimation { duration: 950; easing.type: Easing.OutCubic } }
                                    }
                                    Rectangle { anchors.fill: parent; color: app.pal.surface }
                                    Image {
                                        id: img
                                        anchors.fill: parent
                                        readonly property string thumbUrl: "file://" + cell.modelData.thumbnailPath
                                        readonly property string fullUrl: "file://" + cell.modelData.filePath
                                        property bool useThumb: true
                                        source: useThumb ? thumbUrl : fullUrl
                                        sourceSize.width: cell.selected ? 900 : 300
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                        smooth: true
                                        // thumb missing → fall back to the full image and queue its generation
                                        onStatusChanged: {
                                            if (status === Image.Error && useThumb) {
                                                useThumb = false
                                                app.requestThumb(cell.modelData.filePath, cell.modelData.thumbnailPath)
                                            }
                                        }
                                        // the worker just wrote this cell's thumb → switch to it
                                        Connections {
                                            target: app
                                            function onLastDoneThumbChanged() {
                                                if (!img.useThumb && app.lastDoneThumb === cell.modelData.thumbnailPath)
                                                    img.useThumb = true
                                            }
                                        }
                                    }
                                }

                                // border, following the parallelogram
                                Shape {
                                    anchors.fill: parent
                                    antialiasing: true
                                    preferredRendererType: Shape.CurveRenderer
                                    ShapePath {
                                        fillColor: "transparent"
                                        strokeColor: cell.selected ? app.pal.accent : Qt.rgba(1, 1, 1, 0.12)
                                        strokeWidth: cell.selected ? 3 : 1
                                        startX: cell.topLeft; startY: 0
                                        PathLine { x: cell.topRight; y: 0 }
                                        PathLine { x: cell.bottomRight; y: cell.height }
                                        PathLine { x: cell.bottomLeft; y: cell.height }
                                        PathLine { x: cell.topLeft; y: 0 }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: cell.selected ? app.commit() : (app.sel = cell.index)
                        }
                    }
                }
            }

            // selected label + filter echo
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.verticalCenter; anchors.topMargin: app.expandedH / 2 + 24
                text: app.filtered.length > 0 && app.sel < app.filtered.length ? Model.labelForPath(app.filtered[app.sel].filePath)
                      : (app.filterText ? "No matches" : "")
                color: app.pal.fg; font.family: app.fontFamily; font.pixelSize: 18; font.bold: true
                style: Text.Outline; styleColor: Qt.rgba(0, 0, 0, 0.7)
            }
        }
    }
}
