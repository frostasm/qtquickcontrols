/****************************************************************************
**
** Copyright (C) 2012 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the Qt Components project.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.0
import QtDesktop 1.0
import "content"

ApplicationWindow {
    width: 950
    height: 500

    Components{ id: components }
    SystemPalette { id: syspal }

    toolBar: ToolBar {
        width: parent.width
        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 8
            height: parent.height
            ComboBox {
                id: selector
                width: 200
                model: components.componentModel
            }
            CheckBox {
                id: patternCheckBox
                checked: true
                text: "Background"
            }
            ToolButton {
                id: resetButton
                text: "Reset size"
                onClicked: container.resetSize()
            }
        }
    }

    Flickable {
        id: testBenchRect
        anchors.fill: parent
        clip: true

        Rectangle {
            anchors.fill: parent
            color: "lightgray"
        }

        Image {
            anchors.fill: parent
            anchors.margins: -1000
            source: "../images/checkered.png"
            fillMode: Image.Tile
            opacity: patternCheckBox.checked ? 0.12 : 0
            Behavior on opacity { NumberAnimation { duration: 100 } }
        }

        Rectangle {
            id: container

            property bool pressed: topLeftHandle.pressed || bottomRightHandle.pressed

            function resetSize() {
                topLeftHandle.x = (testBenchRect.width - loader.item.implicitWidth) / 2 - topLeftHandle.width;
                topLeftHandle.y = (testBenchRect.height - loader.item.implicitHeight) / 2 - topLeftHandle.height;
                bottomRightHandle.x = topLeftHandle.x + loader.item.implicitWidth;
                bottomRightHandle.y = topLeftHandle.y + loader.item.implicitHeight;
            }

            y: Math.floor(topLeftHandle.y + topLeftHandle.height - topLeftHandle.width/2)
            x: Math.floor(topLeftHandle.x + topLeftHandle.width - topLeftHandle.height/2)
            width: Math.floor(bottomRightHandle.x - topLeftHandle.x )
            height: Math.floor(bottomRightHandle.y - topLeftHandle.y)
            color: "transparent"
            border.color: pressed ? "darkgray" : "transparent"

            Loader {
                id: loader
                focus: true
                sourceComponent: selector.model.get(selector.selectedIndex).component
                anchors.fill: parent

                onStatusChanged: {
                    if (status == Loader.Ready) {
                        container.resetSize();
                        propertyModel.clear()

                        for (var prop in item) {
                            if (!prop.indexOf("on")) { // look only for properties
                                var substr = prop.slice(2, prop.length - 7)
                                if (!substr.indexOf("__")) // filter private
                                    continue;

                                var typeName = "None";
                                switch (substr) {

                                case "ActiveFocusOnPress":
                                case "Enabled":
                                case "Visible":
//                              case "Focus":
                                    typeName = "Boolean";
                                    break

                                case "MaximumValue":
                                case "MinimumValue":
                                case "Decimals":
                                    typeName = "Int"
                                    break;

                                case "Scale":
                                case "Height":
                                case "Width":
                                case "StepSize":
                                case "Value":
                                case "Opacity":
                                    typeName = "Real";
                                    break;

                                case "ImplicitHeight":
                                case "ActiveFocus":
                                case "ImplicitWidth":
                                case "Pressed":
                                    typeName = "ReadOnly"
                                    break;

                                case "Prefix":
                                case "Suffix":
                                case "Text":
                                case "Title":
                                case "Tooltip":
//                                case "TextColor":
                                    typeName = "String";
                                    break;

                                default:
                                    break;

                                }
                                if (substr.length > 1)
                                    substr = substr[0].toLowerCase() + substr.substring(1)
                                else
                                    substr = substr.toLowerCase()

                                var val = item[substr]+"" // All model properties must be the same type
                                if (typeName != "None" && val !== undefined) {
                                    // We should do a proper sort instead
                                    if (typeName == "Boolean")
                                        propertyModel.insert(0, {name: substr , result: val, typeString: typeName})
                                    else
                                        propertyModel.append({name: substr , result: val, typeString: typeName})
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: marginsRect
                    color: "transparent"
                    // opacity: container.pressed && loader.item.styling && loader.item.styling.topMargin != undefined ? 1 : 0
                    border.color: Qt.rgba(0, 0, 0, 0.2)
                    anchors.fill: parent
                    z: 2
                    Connections {
                        target: loader
                        onItemChanged: {
                            if (!loader.item || !loader.item.styling) return;
                            marginsRect.anchors.leftMargin = Math.max(loader.item.styling.leftMargin, 0);
                            marginsRect.anchors.rightMargin = Math.max(loader.item.styling.rightMargin, 0);
                            marginsRect.anchors.topMargin = Math.max(loader.item.styling.topMargin, 0);
                            marginsRect.anchors.bottomMargin = Math.max(loader.item.styling.bottomMargin, 0);
                        }
                    }
                }
            }
        }

        MouseArea {
            id: topLeftHandle
            width: 10
            height: 10

            drag.target: topLeftHandle
            drag.minimumX: 0; drag.minimumY: 0
            drag.maximumX: bottomRightHandle.x - width
            drag.maximumY: bottomRightHandle.y - height
            Rectangle {
                anchors.fill: parent
                color: "lightsteelblue"
                border.color: "steelblue"
            }
        }

        MouseArea {
            id: bottomRightHandle
            width: 10
            height: 10

            drag.target: bottomRightHandle
            drag.minimumX: topLeftHandle.x + width
            drag.minimumY: topLeftHandle.y + height
            drag.maximumX: testBenchRect.width - width;
            drag.maximumY: testBenchRect.height - height

            Rectangle {
                anchors.fill: parent
                color: "lightsteelblue"
                border.color: "steelblue"
            }
        }
    }



    Rectangle {
        color : syspal.window
        anchors.top: parent.top
        anchors.bottom: parent.bottom; width: 200; anchors.right: parent.right;
        Rectangle {
            width: 1
            height: parent.height
            color: Qt.darker(parent.color, 1.4)
        }

        ScrollArea {
            id: scrollArea
            anchors.fill: parent

            Column {
                id: properties
                anchors.left: parent ? parent.left : undefined
                anchors.top: parent ? parent.top : undefined
                anchors.margins: 10
                width: scrollArea.viewport.width
                spacing: 8
                Repeater {
                    model: ListModel { id: propertyModel }
                    Column {
                        property bool isEnabled: typeString !== "ReadOnly"
                        width: properties.width
                        CheckBox {
                            visible: typeString == "Boolean"
                            checked: visible ? result : false
                            text: name
                            onCheckedChanged: if (isEnabled) loader.item[name] = checked
                        }

                        RowLayout {
                            spacing: 4
                            width: parent.width - 16
                            visible: typeString == "Int"
                            Text {
                                text: name + ":"
                                Layout.minimumWidth: 100
                            }
                            SpinBox {
                                value: result
                                maximumValue: 9999
                                Layout.horizontalSizePolicy: Layout.Expanding
                                onValueChanged: if (isEnabled) loader.item[name] = value
                            }
                        }

                        RowLayout {
                            spacing: 4
                            width: parent.width - 16
                            visible: typeString == "Real"
                            Text {
                                text: name + ":"
                                Layout.minimumWidth: 100
                            }
                            SpinBox {
                                value: result
                                decimals: 1
                                stepSize: 0.5
                                maximumValue: 9999
                                Layout.horizontalSizePolicy: Layout.Expanding
                                onValueChanged: if (isEnabled) loader.item[name] = value
                            }
                        }

                        RowLayout {
                            spacing: 4
                            visible: typeString == "String"
                            width: parent.width - 16
                            Text {
                                text: name + ":"
                                width: 100
                            }
                            TextField {
                                id: tf
                                text: result
                                onTextChanged: if (isEnabled) loader.item[name] = tf.text
                                Layout.horizontalSizePolicy: Layout.Expanding
                            }
                        }

                        RowLayout {
                            height: 20
                            visible: typeString == "ReadOnly"
                            Text {
                                id: text
                                height: 20
                                text: name + ":"
                            }
                            Text {
                                height: 20
                                anchors.right: parent.right
                                text: loader.item[name] ? loader.item[name] : ""
                            }
                        }
                    }
                }
            }
        }
    }
}