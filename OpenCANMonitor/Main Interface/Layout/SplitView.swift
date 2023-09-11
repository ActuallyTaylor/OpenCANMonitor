//
//  SplitView.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import SwiftUI

struct SplitView: View {
    enum Direction {
        case horizontal
        case vertical
    }
    
    var direction: Direction = .vertical
    
    var childOne: AnyView
    var childTwo: AnyView?
    
    var startingDividerLocation = 0.5

    @Binding var externalChildOnePercent: CGFloat
    @Binding var externalChildTwoPercent: CGFloat

    @State var childOnePercent: CGFloat = 0.5
    @State var childTwoPercent: CGFloat = 0.5
    
    @State var percentOffset: CGFloat = 0
    
    @State var hoveringDivider: Bool = false
    
    var dividerSize: CGFloat = 3
    
    var body: some View {
        GeometryReader { reader in
            if direction == .vertical {
                VStack(spacing: 0) {
                    childOne
                        .frame(height: (reader.size.height - (dividerSize / 2)) * (childOnePercent + percentOffset))
                        .clipped()
                    if let childTwo {
                        divider(reader)
                            .frame(height: dividerSize)
                        childTwo
                            .frame(height: (reader.size.height - (dividerSize / 2)) * (childTwoPercent - percentOffset))
                            .clipped()
                    }
                }
                .coordinateSpace(name: "split")
            } else {
                HStack(spacing: 0) {
                    childOne
                        .frame(width: (reader.size.width - (dividerSize / 2)) * (childOnePercent + percentOffset))
                        .clipped()
                    if let childTwo {
                        divider(reader)
                            .frame(width: dividerSize)
                        childTwo
                            .frame(width: (reader.size.width - (dividerSize / 2)) * (childTwoPercent - percentOffset))
                            .clipped()
                    }
                }
                .coordinateSpace(name: "split")
            }
        }
        .onChange(of: externalChildOnePercent) { newValue in
            childOnePercent = newValue
            childTwoPercent = 1 - newValue
        }
        .onChange(of: externalChildTwoPercent) { newValue in
            childTwoPercent = newValue
            childOnePercent = 1 - newValue
        }
    }
            
    @ViewBuilder
    private func divider(_ reader: GeometryProxy) -> some View {
        if childOnePercent == 0 || childTwoPercent == 0 {
            EmptyView()
        } else {
            Rectangle()
                .foregroundColor(.clear)
                .overlay(alignment: .center) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .foregroundColor(.accentColor.opacity(0.5))
                        RoundedRectangle(cornerRadius: 7)
                            .foregroundColor(.gray.opacity(0.5))
                            .frame(width: direction == .vertical ? 30 : dividerSize - 2, height: direction == .vertical ? dividerSize - 2 : 30)
                    }
                }
                .onHover(perform: { isHovering in
                    if isHovering {
                        if direction == .vertical {
                            NSCursor.resizeUpDown.push()
                        } else if direction == .horizontal {
                            NSCursor.resizeLeftRight.push()
                        }
                    } else {
                        NSCursor.pop()
                    }
                })
                .gesture(DragGesture(coordinateSpace: .named("split"))
                    .onChanged { value in
                        if direction == .vertical && NSCursor.current != NSCursor.resizeUpDown {
                            NSCursor.resizeUpDown.push()
                        } else if direction == .horizontal && NSCursor.current != NSCursor.resizeLeftRight {
                            NSCursor.resizeLeftRight.push()
                        }
                        
                        let adjustedLocation = direction == .vertical ? value.location.y : value.location.x
                        let percent =  (adjustedLocation / (direction == .vertical ? reader.size.height : reader.size.width)) - startingDividerLocation
                        percentOffset = percent
                        
                        if percentOffset >= (1 - startingDividerLocation - 0.01) {
                            percentOffset = (1 - startingDividerLocation - 0.01)
                        } else if percentOffset <= -(startingDividerLocation - 0.01) {
                            percentOffset = -(startingDividerLocation - 0.01)
                        }
                    }
                    .onEnded { value in
                        NSCursor.pop()
                        let adjustedLocation = direction == .vertical ? value.location.y : value.location.x
                        let percent =  (adjustedLocation / (direction == .vertical ? reader.size.height : reader.size.width)) - startingDividerLocation
                        
                        percentOffset = percent
                        if percentOffset >= (1 - startingDividerLocation - 0.01) {
                            percentOffset = (1 - startingDividerLocation - 0.01)
                        } else if percentOffset <= -(startingDividerLocation - 0.01) {
                            percentOffset = -(startingDividerLocation - 0.01)
                        }
                    }
                )
        }
    }
}

struct SplitView_Previews: PreviewProvider {
    static var previews: some View {
        SplitView {
            Color.red
            Color.green
        }
    }
}

extension SplitView {
    public init<c0: View>(_ direction: Direction = .vertical, splitOnePercent: Binding<CGFloat>, splitTwoPercent: Binding<CGFloat>, @ViewBuilder content: () -> c0) {
        self.childOne = AnyView(content())
        self.childTwo = nil
        self.direction = direction

        childOnePercent = splitOnePercent.wrappedValue
        startingDividerLocation = splitOnePercent.wrappedValue
        childTwoPercent = splitTwoPercent.wrappedValue
        
        _externalChildOnePercent = splitOnePercent
        _externalChildTwoPercent = splitTwoPercent
    }
    
    public init<c0: View>(_ direction: Direction = .vertical, splitOnePercent: CGFloat = 1, splitTwoPercent: CGFloat = 0, @ViewBuilder content: () -> c0) {
        self.childOne = AnyView(content())
        self.childTwo = nil
        self.direction = direction

        childOnePercent = splitOnePercent
        startingDividerLocation = splitOnePercent
        childTwoPercent = splitTwoPercent
        
        _externalChildOnePercent = .constant(splitOnePercent)
        _externalChildTwoPercent = .constant(splitTwoPercent)
    }
    
    public init<c0: View>(_ direction: Direction = .vertical, splitOnePercent: Binding<CGFloat>, splitTwoPercent: CGFloat = 0, @ViewBuilder content: () -> c0) {
        self.childOne = AnyView(content())
        self.childTwo = nil
        self.direction = direction

        childOnePercent = splitOnePercent.wrappedValue
        startingDividerLocation = splitOnePercent.wrappedValue
        childTwoPercent = splitTwoPercent
        
        _externalChildOnePercent = splitOnePercent
        _externalChildTwoPercent = .constant(splitTwoPercent)
    }

    public init<c0: View>(_ direction: Direction = .vertical, splitOnePercent: CGFloat = 1, splitTwoPercent: Binding<CGFloat>, @ViewBuilder content: () -> c0) {
        self.childOne = AnyView(content())
        self.childTwo = nil
        self.direction = direction

        childOnePercent = splitOnePercent
        startingDividerLocation = splitOnePercent
        childTwoPercent = splitTwoPercent.wrappedValue
        
        _externalChildOnePercent = .constant(splitOnePercent)
        _externalChildTwoPercent = splitTwoPercent
    }


    // MARK: Two Views
    public init<c0: View, c1: View>(_ direction: Direction = .vertical, splitOnePercent: CGFloat = 0.5, splitTwoPercent: CGFloat = 0.5, @ViewBuilder content: () -> TupleView<(c0, c1)>) {
        let views = content().value
        self.childOne = AnyView(views.0)
        self.childTwo = AnyView(views.1)
        self.direction = direction
        
        childOnePercent = splitOnePercent
        startingDividerLocation = splitOnePercent
        childTwoPercent = splitTwoPercent
        
        _externalChildOnePercent = .constant(splitOnePercent)
        _externalChildTwoPercent = .constant(splitTwoPercent)
    }

    public init<c0: View, c1: View>(_ direction: Direction = .vertical, splitOnePercent: Binding<CGFloat>, splitTwoPercent: Binding<CGFloat>, @ViewBuilder content: () -> TupleView<(c0, c1)>) {
        let views = content().value
        self.childOne = AnyView(views.0)
        self.childTwo = AnyView(views.1)
        self.direction = direction
        
        childOnePercent = splitOnePercent.wrappedValue
        startingDividerLocation = splitOnePercent.wrappedValue
        childTwoPercent = splitTwoPercent.wrappedValue
        
        _externalChildOnePercent = splitOnePercent
        _externalChildTwoPercent = splitTwoPercent
    }
    
    public init<c0: View, c1: View>(_ direction: Direction = .vertical, splitOnePercent: Binding<CGFloat>, splitTwoPercent: CGFloat = 0.5, @ViewBuilder content: () -> TupleView<(c0, c1)>) {
        let views = content().value
        self.childOne = AnyView(views.0)
        self.childTwo = AnyView(views.1)
        self.direction = direction
        
        childOnePercent = splitOnePercent.wrappedValue
        startingDividerLocation = splitOnePercent.wrappedValue
        childTwoPercent = splitTwoPercent
        
        _externalChildOnePercent = splitOnePercent
        _externalChildTwoPercent = .constant(splitTwoPercent)
    }
    
    public init<c0: View, c1: View>(_ direction: Direction = .vertical, splitOnePercent: CGFloat = 0.5, splitTwoPercent: Binding<CGFloat>, @ViewBuilder content: () -> TupleView<(c0, c1)>) {
        let views = content().value
        self.childOne = AnyView(views.0)
        self.childTwo = AnyView(views.1)
        self.direction = direction
        
        childOnePercent = splitOnePercent
        startingDividerLocation = splitOnePercent
        childTwoPercent = splitTwoPercent.wrappedValue
        
        _externalChildOnePercent = .constant(splitOnePercent)
        _externalChildTwoPercent = splitTwoPercent
    }
}
