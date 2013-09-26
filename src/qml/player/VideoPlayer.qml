/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Ugo Riboni <ugo.riboni@canonical.com>
 *  Michał Sawicz <michal.sawicz@canonical.com>
 *  Renato Araujo Oliveira Filho <renato@canonical.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import QtMultimedia 5.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Extras 0.1
import Ubuntu.Components.Popups 0.1 as Popups
import "../common"
import "../sdk"

AbstractPlayer {
    id: player

    property variant nfo
    property int pressCount: 0
    property bool wasPlaying: false
    property string uri
    property bool rotating: false
    property alias controlsActive: _controls.active
    property bool componentLoaded: false

    signal timeClicked

    objectName: "player"
    nfo: VideoInfo {
        uri: source
    }

    function playUri(uri) {
        source = uri
        if (componentLoaded) {
            play()
        }
    }

    Component.onCompleted: {
        componentLoaded = true
        if ((state !== "playing") && (source != "")) {
            play()
        }
    }

    function edgeEvent(event) {
        event.accepted = true
    }

    function startSharing() {
        player.controlsActive = true;
        _sharePopover.caller = _controls;
        _sharePopover.show();
    }

    function playPause() {
        if (["paused", "playing"].indexOf(player.state) != -1) {
            player.togglePause();
        } else {
            player.play();
        }
    }

//TODO: blur effect does not work fine without multiple thread rendering
//    ControlsMask {
//        anchors.fill: parent
//        controls: _controls
//        videoOutput: player.videoOutput
//    }

    GenericToolbar {
        id: _controls

        objectName: "toolbar"
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: _controlsContents.height

        Controls {
            id: _controlsContents

            property bool isPaused: false

            objectName: "controls"
            state: player.state
            video: player.video
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            maximumHeight: units.gu(27)
            sceneSelectorHeight: units.gu(18)

            onPlaybackClicked: player.playPause()

            onFullscreenClicked: {
                //TODO: wait for shell supports fullscreen
                Qt.quit()
            }

            onSeekRequested: {
                player.video.seek(time)
            }

            onStartSeek: {
                isPaused = (state == "paused")
                player.pause()
            }

            onEndSeek: {
                if (!isPaused) {
                    player.play()
                }
            }

            onShareClicked: player.startSharing()
        }
    }

    MouseArea {
        id: _mouseArea

        objectName: "videoMouseArea"
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: _controls.top
        }

        onClicked: _controls.active = !_controls.active
    }

    SharePopover {
        id: _sharePopover
        visible: false
        onSelected: {
            var position = video.position
            if (position === 0) {
                if (video.duration > 10000) {
                    position = 10000;
                } else if (video.duration > 0){
                    position = video.duration / 2
                }
            }
            if (position >= 0) {
                _share.fileToShare = "image://video/" + video.source + "/" + position;
            }
            _share.userAccountId = accountId;
            _share.visible = true;
        }
    }

    Share {
        id: _share
        visible: false
        anchors.fill: parent
        onCanceled: _share.visible = false
        onUploadCompleted: _share.visible = false
    }
}
