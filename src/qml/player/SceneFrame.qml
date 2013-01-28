/*
 * Copyright (C) 2013 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

MouseArea {
    id: _imageFrame

    property int start
    property int duration
    property alias source: _image.source
    property bool active: false

    Behavior on width {
        NumberAnimation { duration: 175 }
    }

    UbuntuShape {
        id: _shape
        radius: "medium"

        anchors {
            fill: parent
            topMargin: active ? 0 : units.gu(2)
            bottomMargin: active ? 0 : units.gu(2)
            leftMargin: units.gu(1)
            rightMargin: units.gu(1)

            Behavior on topMargin {
                NumberAnimation { duration: 175 }
            }

            Behavior on bottomMargin {
                NumberAnimation { duration: 175 }
            }
        }


        image: Image {
            id: _image

            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: true
        }
    }

    ActivityIndicator {
        id: imgLoading

        anchors {
            fill: _shape
            margins: units.gu(0.5)
        }

        running: _image.status != Image.Ready
        visible: running
    }
}
