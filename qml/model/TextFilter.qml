import QtQuick 2.0
import Felgo 3.0

QtObject {
  property string filterText: ""
  property bool matchCase: false
  property bool matchPartial: false

  signal propertyChanged

  onFilterTextChanged: propertyChanged()
  onMatchCaseChanged: propertyChanged()
  onMatchPartialChanged: propertyChanged()
}
