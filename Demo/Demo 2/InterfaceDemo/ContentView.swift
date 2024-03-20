//
//  ContentView.swift
//  InterfaceDemo
//
//  Created by Mark on 20/03/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedPage: Page = .red
    
    @State private var presentPagePicker: Bool = false
    @State private var offsetPagePicker: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(selectedPage.color)
                    .ignoresSafeArea()
                Text(selectedPage.name)
                    .font(.system(size: 100))
                    .foregroundStyle(.white)
                PagePicker(selectedPage: $selectedPage)
                    .opacity(presentPagePicker ? 1 : 0)
                    .scaleEffect(presentPagePicker ? 1 : 0.5)
                    .offset(y: offsetPagePicker)
                    .onDragGesture([.down, .up]) {proxy in
                        if proxy.phase == .down {
                            var y = proxy.value.startLocation.y - (geometry.size.height / 2)
                            y = y < 0 ? y + (proxy.geometry.size.height) : y - (proxy.geometry.size.height)
                            offsetPagePicker = y
                        }
                        withAnimation {
                            presentPagePicker = (proxy.phase == .down)
                        }
                    }
            }
        }
        .coordinateSpace(.named("page"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dragGestureObserver(coordinateSpace: .named("page"))
    }
}

enum Page: Int, CaseIterable, Identifiable {
    case red
    case orange
    case yellow
    case blue
    case indigo
    
    var id: Int { self.rawValue }
    
    var name: String {
        "\(self.rawValue + 1)"
    }
    
    var color: Color {
        switch self {
        case .red: .red
        case .orange: .orange
        case .yellow: .yellow
        case .blue: .blue
        case .indigo: .indigo
        }
    }
}

struct PagePicker: View {
    @Binding var selectedPage: Page
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(Page.allCases) { page in
                PagePickerButton(page: page, selectedPage: $selectedPage)
            }
        }
        .padding([.leading, .trailing], 40.0)
    }
}

struct PagePickerButton: View {
    let page: Page
    @Binding var selectedPage: Page
    
    @State private var isHighlighted: Bool = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isHighlighted ? .white : .clear)
                .stroke(.white, lineWidth: 3.0)
            Text(page.name)
                .font(.system(size: 24.0))
                .fontWeight(.bold)
                .foregroundStyle(isHighlighted ? selectedPage.color : .white)
        }
        .onDragGesture { proxy in
            if proxy.phase == .upInside {
                selectedPage = page
            }
            if proxy.phase == .downInside || proxy.phase == .moveInside {
                isHighlighted = true
            } else if proxy.phase == .moveOutside || proxy.phase == .up {
                isHighlighted = false
            }
        }
    }
}

#Preview {
    ContentView()
}
