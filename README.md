# DragGestureObserver

An extension to SwiftUI that will add control events to your views.

## Installation

Download the DragGestureObserver.swift file and add it to your project.

## Methods

```swift
func dragGestureObserver() -> some View
func onDragGesture(_ phase: DragGesture.Phase, action: @escaping (DragGestureProxy) -> Void) -> some View
func onDragGesture(_ phases: [DragGesture.Phase] = DragGesture.Phase.allCases, action: @escaping (DragGestureProxy) -> Void) -> some View
```

```swift
extension DragGesture {
    enum Phase: CaseIterable {
        case down
        case downInside
        case downOutside
        case up
        case upInside
        case upOutside
        case move
        case moveInside
        case moveOutside
        case enter
        case exit
    }
}

struct DragGestureProxy {
    let phase: DragGesture.Phase
    let value: DragGesture.Value
    let geometry: GeometryProxy
}
```

## Usage

```swift
import SwiftUI

struct ContentView: View {
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        VStack {
            Text("Click Me")
                .fontWeight(.bold)
                .foregroundStyle(isPressed ? .blue : .white)
                .padding()
                .onDragGesture([.downInside, .up]) { proxy in
                    self.isPressed = (proxy.phase == .downInside)
                }
        }
        .dragGestureObserver()
    }
    
}
```

## Donate

If you have been enjoying my free Swift file, please consider showing your support by buying me a coffee through the link below. Thanks in advance!

<a href="https://www.buymeacoffee.com/markvanwijnen" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/arial-yellow.png" height="60px" alt="Buy Me A Coffee"></a>
