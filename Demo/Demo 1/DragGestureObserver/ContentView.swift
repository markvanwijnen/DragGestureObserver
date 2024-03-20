//
//  ContentView.swift
//  DragGestureObserver
//
//  Created by Mark on 20/03/2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        VStack {
            Text("Click me")
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

struct CalculatorDisplay: View {
    @Binding var displayValue: String
    
    var body: some View {
        Text(displayValue)
            .foregroundStyle(.white)
            .font(.system(size: 100))
    }
}

struct CalculatorButton: View {
    let number: Int
    @Binding var displayValue: String
    
    @State private var isHighlighted: Bool = false
    
    init(_ number: Int, displayValue: Binding<String>) {
        self.number = number
        self._displayValue = displayValue
    }
    
    var body: some View {
        Text("\(number)")
            .font(.system(size: 40))
            .foregroundStyle(.white)
            .frame(width: 70, height: 70)
            .background(
                Circle().fill(
                    !isHighlighted ?
                        Color(red: 51/255, green: 51/255, blue: 51/255) :
                        Color(red: 115/255, green: 115/255, blue: 115/255)
                )
            )
            .padding(7)
            .onDragGesture([.downInside, .up, .upInside, .enter, .exit]) {proxy in
                if proxy.phase == .downInside || proxy.phase == .enter {
                    self.isHighlighted = true
                } else if proxy.phase == .up || proxy.phase == .exit {
                    self.isHighlighted = false
                } else if proxy.phase == .upInside {
                    self.displayValue = "\(number)"
                }
            }
            .animation(.spring, value: isHighlighted)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
