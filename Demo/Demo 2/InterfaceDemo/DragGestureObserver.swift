//
//  DragGestureObserver.swift
//  DragGestureObserver
//
//  Created by Mark on 20/03/2024.
//

import SwiftUI
import Combine

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

fileprivate struct _DragGestureObserverPublisherKey: EnvironmentKey {
    static let defaultValue = _DragGestureObserver.Publisher()
}

extension EnvironmentValues {
    fileprivate var _dragGestureObserverPublisher: _DragGestureObserver.Publisher {
        get { self[_DragGestureObserverPublisherKey.self] }
        set { self[_DragGestureObserverPublisherKey.self] = newValue }
    }
}

extension _DragGestureObserver {
    enum Event {
        case changed(DragGesture.Value, CoordinateSpace)
        case ended(DragGesture.Value, CoordinateSpace)
    }
}

fileprivate struct _DragGestureObserver: ViewModifier {
    typealias Publisher = PassthroughSubject<_DragGestureObserver.Event, Never>
    
    private let coordinateSpace: CoordinateSpace
    @State private var publisher = Publisher()
    
    private var dragGesture : some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: coordinateSpace)
            .onChanged {publisher.send(_DragGestureObserver.Event.changed($0, coordinateSpace))}
            .onEnded {publisher.send(_DragGestureObserver.Event.ended($0, coordinateSpace))}
    }
    
    init(coordinateSpace: CoordinateSpace = .global) {
        self.coordinateSpace = coordinateSpace
    }
    
    func body(content: Content) -> some View {
        content
            .gesture(dragGesture)
            .environment(\._dragGestureObserverPublisher, publisher)
    }
}

extension View {
    func dragGestureObserver(coordinateSpace: CoordinateSpace = .global) -> some View {
        modifier(_DragGestureObserver(coordinateSpace: coordinateSpace))
    }
}


fileprivate struct _OnDragGesture: ViewModifier {
    let phases: [DragGesture.Phase]
    let action: (DragGestureProxy) -> Void
    
    @Environment(\._dragGestureObserverPublisher) private var publisher: _DragGestureObserver.Publisher
    
    @State private var geometry: GeometryProxy?
    @State private var currentDragGestureValue: DragGesture.Value?
    
    init(_ phases: [DragGesture.Phase] = DragGesture.Phase.allCases, action: @escaping (DragGestureProxy) -> Void) {
        self.phases = phases
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {self.geometry = geometry}
                        .onChange(of: geometry.size) {self.geometry = geometry}
                }
            )
            .onReceive(publisher) {event in
                guard let geometry = geometry else { return }
                
                switch event {
                case .changed(let value, let coordinateSpace):
                    if let previousDragGestureValue = currentDragGestureValue {
                        if phases.contains(.move) {action(DragGestureProxy(phase: .move, value: value, geometry: geometry))}
                        if geometry.frame(in: coordinateSpace).contains(value.location) {
                            if phases.contains(.moveInside) {action(DragGestureProxy(phase: .moveInside, value: value, geometry: geometry))}
                        } else {
                            if phases.contains(.moveOutside) {action(DragGestureProxy(phase: .moveOutside, value: value, geometry: geometry))}
                        }
                        if !geometry.frame(in: coordinateSpace).contains(previousDragGestureValue.location) &&
                            geometry.frame(in: coordinateSpace).contains(value.location) {
                            if phases.contains(.enter) {action(DragGestureProxy(phase: .enter, value: value, geometry: geometry))}
                        }
                        if geometry.frame(in: coordinateSpace).contains(previousDragGestureValue.location) &&
                            !geometry.frame(in: coordinateSpace).contains(value.location) {
                            if phases.contains(.exit) {action(DragGestureProxy(phase: .exit, value: value, geometry: geometry))}
                        }
                    } else {
                        if phases.contains(.down) {action(DragGestureProxy(phase: .down, value: value, geometry: geometry))}
                        if geometry.frame(in: coordinateSpace).contains(value.location) {
                            if phases.contains(.downInside) {action(DragGestureProxy(phase: .downInside, value: value, geometry: geometry))}
                        } else {
                            if phases.contains(.downOutside) {action(DragGestureProxy(phase: .downOutside, value: value, geometry: geometry))}
                        }
                    }
                    currentDragGestureValue = value
                case .ended(let value, let coordinateSpace):
                    if phases.contains(.up) {action(DragGestureProxy(phase: .up, value: value, geometry: geometry))}
                    if geometry.frame(in: coordinateSpace).contains(value.location) {
                        if phases.contains(.upInside) {action(DragGestureProxy(phase: .upInside, value: value, geometry: geometry))}
                    } else {
                        if phases.contains(.upOutside) {action(DragGestureProxy(phase: .upOutside, value: value, geometry: geometry))}
                    }
                    currentDragGestureValue = nil
                }
            }
    }
}

extension View {
    func onDragGesture(_ phase: DragGesture.Phase, action: @escaping (DragGestureProxy) -> Void) -> some View {
        modifier(_OnDragGesture([phase], action: action))
    }
    
    func onDragGesture(_ phases: [DragGesture.Phase] = DragGesture.Phase.allCases, action: @escaping (DragGestureProxy) -> Void) -> some View {
        modifier(_OnDragGesture(phases, action: action))
    }
}
