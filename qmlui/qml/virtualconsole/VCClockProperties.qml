/*
  Q Light Controller Plus
  VCClockProperties.qml

  Copyright (c) Massimo Callegari

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0.txt

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2

import com.qlcplus.classes 1.0
import "."

Rectangle
{
    color: "transparent"
    height: cPropsColumn.height

    property VCClock widgetRef: null

    property int gridItemsHeight: 38

    Column
    {
        id: cPropsColumn
        width: parent.width
        spacing: 5

        SectionBox
        {
            id: clockTypeProps
            sectionLabel: qsTr("Clock type")

            sectionContents:
              GridLayout
              {
                width: parent.width
                columns: 2
                columnSpacing: 5
                rowSpacing: 4

                ExclusiveGroup { id: clockTypeGroup }

                // row 1
                RobotoText { fontSize: 14; label: qsTr("Clock") }

                CustomCheckBox
                {
                    width: gridItemsHeight
                    height: gridItemsHeight
                    exclusiveGroup: clockTypeGroup
                    checked: widgetRef ? widgetRef.clockType === VCClock.Clock : false
                    onCheckedChanged: if (checked && widgetRef) widgetRef.clockType = VCClock.Clock
                }

                // row 2
                RobotoText { fontSize: 14; label: qsTr("Stopwatch") }

                CustomCheckBox
                {
                    width: gridItemsHeight
                    height: gridItemsHeight
                    exclusiveGroup: clockTypeGroup
                    checked: widgetRef ? widgetRef.clockType === VCClock.Stopwatch : false
                    onCheckedChanged: if (checked && widgetRef) widgetRef.clockType = VCClock.Stopwatch
                }

                // row 3
                RobotoText { fontSize: 14; label: qsTr("Countdown") }

                CustomCheckBox
                {
                    id: cdownCheck
                    width: gridItemsHeight
                    height: gridItemsHeight
                    exclusiveGroup: clockTypeGroup
                    checked: widgetRef ? widgetRef.clockType === VCClock.Countdown : false
                    onCheckedChanged: if (checked && widgetRef) widgetRef.clockType = VCClock.Countdown
                }

                DayTimeTool
                {
                    visible: cdownCheck.checked
                    Layout.columnSpan: 2
                    timeValue: widgetRef ? widgetRef.targetTime / 1000 : 0

                    onTimeValueChanged: widgetRef.targetTime = timeValue * 1000
                }
              } // GridLayout
        } // SectionBox

        SectionBox
        {
            id: scheduleProps
            sectionLabel: qsTr("Schedule")

            sectionContents:
                Column
                {
                    width: parent.width

                    Rectangle
                    {
                        color: UISettings.bgMedium
                        width: parent.width
                        height: 40

                        IconButton
                        {
                            id: addSchedule
                            anchors.top: parent.top
                            anchors.right: parent.right

                            width: height
                            height: 38
                            imgSource: "qrc:/add.svg"
                            checkable: true
                            tooltip: qsTr("Add a function schedule")
                            onCheckedChanged:
                            {
                                if (checked)
                                {
                                    vcRightPanel.width += 350
                                    funcMgrLoader.width = 350
                                    funcMgrLoader.source = "qrc:/FunctionManager.qml"
                                }
                                else
                                {
                                    vcRightPanel.width = vcRightPanel.width - funcMgrLoader.width
                                    funcMgrLoader.source = ""
                                    funcMgrLoader.width = 0
                                }
                            }
                        }
                    }

                    ListView
                    {
                        id: schListView
                        width: parent.width
                        height: model.length * 180
                        boundsBehavior: Flickable.StopAtBounds

                        model: widgetRef.scheduleList
                        delegate:
                            Rectangle
                            {
                                width: parent.width
                                height: 180
                                color: "transparent"

                                property VCClockSchedule schedule: modelData
                                property Function func

                                GridLayout
                                {
                                    anchors.fill: parent
                                    columns: 2
                                    columnSpacing: 3
                                    rowSpacing: 3

                                    // row 1
                                    IconTextEntry
                                    {
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true

                                        fontSize: 14

                                        Component.onCompleted:
                                        {
                                            func = functionManager.getFunction(schedule.functionID)
                                            tLabel = func.name
                                            functionType = func.type
                                        }

                                        IconButton
                                        {
                                            id: fontButton
                                            anchors.top: parent.top
                                            anchors.right: parent.right
                                            imgSource: "qrc:/cancel.svg"
                                            tooltip: qsTr("Remove this schedule")
                                            onClicked:
                                            {
                                                widgetRef.removeSchedule(index)
                                            }
                                        }
                                    }

                                    // row 2
                                    RobotoText
                                    {
                                        label: qsTr("Start time")
                                    }
                                    DayTimeTool
                                    {
                                        timeValue: schedule ? schedule.startTime : 0
                                    }

                                    // row 3
                                    RobotoText
                                    {
                                        label: qsTr("Stop time")
                                    }
                                    Rectangle
                                    {
                                        height: 40
                                        Layout.fillWidth: true
                                        color: "transparent"
                                        Row
                                        {
                                            spacing: 5
                                            DayTimeTool
                                            {
                                                timeValue: schedule ? schedule.stopTime : 0

                                                Rectangle
                                                {
                                                    anchors.fill: parent
                                                    color: "black"
                                                    opacity: 0.7
                                                    visible: !stEnableCheck.checked
                                                }
                                            }
                                            CustomCheckBox
                                            {
                                                id: stEnableCheck
                                                tooltip: qsTr("Enable the stop time")
                                                checked: schedule ? schedule.stopTime !== -1 : false
                                            }
                                        }
                                    }

                                    Row
                                    {
                                        Layout.columnSpan: 2
                                        spacing: 1

                                        RobotoText { label: qsTr("M") }
                                        CustomCheckBox
                                        {
                                            checked: schedule ? schedule.weekFlags & 0x01 : false
                                            onCheckedChanged:
                                            {
                                                if(checked) schedule.weekFlags = schedule.weekFlags | 0x01
                                                else schedule.weekFlags &= ~0x01
                                            }
                                        }

                                        RobotoText { label: qsTr("T") }
                                        CustomCheckBox
                                        {
                                            checked: schedule ? schedule.weekFlags & 0x02 : false
                                            onCheckedChanged:
                                            {
                                                if(checked) schedule.weekFlags |= 0x02
                                                else schedule.weekFlags &= ~0x02
                                            }
                                        }

                                        RobotoText { label: qsTr("W") }
                                        CustomCheckBox
                                        {
                                            checked: schedule ? schedule.weekFlags & 0x04 : false
                                            onCheckedChanged:
                                            {
                                                if(checked) schedule.weekFlags |= 0x04
                                                else schedule.weekFlags &= ~0x04
                                            }
                                        }

                                        RobotoText { label: qsTr("T") }
                                        CustomCheckBox
                                        {
                                            checked: schedule ? schedule.weekFlags & 0x08 : false
                                            onCheckedChanged:
                                            {
                                                if(checked) schedule.weekFlags |= 0x08
                                                else schedule.weekFlags &= ~0x08
                                            }
                                        }

                                        RobotoText { label: qsTr("F") }
                                        CustomCheckBox
                                        {
                                            checked: schedule ? schedule.weekFlags & 0x10 : false
                                            onCheckedChanged:
                                            {
                                                if(checked) schedule.weekFlags |= 0x10
                                                else schedule.weekFlags &= ~0x10
                                            }
                                        }

                                        RobotoText { label: qsTr("S") }
                                        CustomCheckBox
                                        {
                                            checked: schedule ? schedule.weekFlags & 0x20 : false
                                            onCheckedChanged:
                                            {
                                                if(checked) schedule.weekFlags |= 0x20
                                                else schedule.weekFlags &= ~0x20
                                            }
                                        }

                                        RobotoText { label: qsTr("S") }
                                        CustomCheckBox
                                        {
                                            checked: schedule ? schedule.weekFlags & 0x40 : false
                                            onCheckedChanged:
                                            {
                                                if(checked) schedule.weekFlags |= 0x40
                                                else schedule.weekFlags &= ~0x40
                                            }
                                        }

                                        IconButton
                                        {
                                            imgSource: "qrc:/loop.svg"
                                            checkable: true
                                            checked: schedule ? schedule.weekFlags & 0x80 : false
                                            tooltip: qsTr("Repeat weekly")
                                            onCheckedChanged:
                                            {
                                                if(checked) schedule.weekFlags |= 0x80
                                                else schedule.weekFlags &= ~0x80
                                            }
                                        }
                                    }

                                }

                                // items divider
                                Rectangle
                                {
                                    width: parent.width
                                    height: 1
                                    y: parent.height - 1
                                    color: UISettings.fgMedium
                                }
                            }
                    } // end of ListView

                    Rectangle
                    {
                        id: newScheduleBox
                        height: 100
                        width: parent.width
                        color: "transparent"
                        radius: 10

                        RobotoText
                        {
                            id: ntText
                            visible: false
                            anchors.centerIn: parent
                            label: qsTr("Add a new schedule")
                        }

                        DropArea
                        {
                            id: newScheduleDrop
                            anchors.fill: parent

                            keys: [ "function" ]

                            states: [
                                State
                                {
                                    when: newScheduleDrop.containsDrag
                                    PropertyChanges
                                    {
                                        target: newScheduleBox
                                        color: "#3F00FF00"
                                    }
                                    PropertyChanges
                                    {
                                        target: ntText
                                        visible: true
                                    }
                                }
                            ]

                            onDropped:
                            {
                                console.log("Function item dropped here. x: " + drag.x + " y: " + drag.y)
                                widgetRef.addSchedule(drag.source.funcID)
                            }
                        }
                    }
                } // end of Column
        } // end of SectionBox
    } // Column
}
