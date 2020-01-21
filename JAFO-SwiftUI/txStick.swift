//
//  txStick.swift
//  BLETest
//
//  Created by David Mcqueeney on 1/16/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import SwiftUI
import Combine

struct txStick: View {
    
    private let vert: Double
    private let horiz: Double
    
    init(vert: Double, horiz: Double) {
        self.vert = vert
        self.horiz = horiz
    }
    var body: some View {
        GeometryReader { gR in
            //Rectangle().stroke(Color.blue, lineWidth:4).frame(width: gR.size.width , height: gR.size.height).cornerRadius(25)
            Rectangle().foregroundColor(Color.blue).opacity(0.4).frame(width: gR.size.width , height: gR.size.height).cornerRadius(15)
            Circle().fill(Color.yellow).frame(width: gR.size.width/8, height: gR.size.height/8).position(x: gR.size.width/2 + CGFloat(self.horiz) * gR.size.width / 2, y: gR.size.height/2 + CGFloat(self.vert) * gR.size.height / 2)
            txTicks().foregroundColor(Color.yellow)
        }
    }
}

struct txTicks: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x:rect.minX, y:rect.midY))
        path.addLine(to: CGPoint(x:rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x:rect.midX, y: rect.midY))
        path.addLine(to: CGPoint(x:rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x:rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x:rect.midX, y: rect.midY))
        for i in -4 ... 4 {
            path.move(to: CGPoint(x:rect.midX + CGFloat(i) * rect.maxX/10, y: rect.midY - rect.maxY/30))
            path.addLine(to: CGPoint(x:rect.midX + CGFloat(i) * rect.maxX/10, y: rect.midY + rect.maxY/30))
            path.move(to: CGPoint(x: rect.midX - rect.maxX/30, y: rect.midY + CGFloat(i) * rect.maxY / 10))
            path.addLine(to: CGPoint(x: rect.midX + rect.maxX/30, y: rect.midY + CGFloat(i) * rect.maxY / 10))
        }
        return path.strokedPath(StrokeStyle(lineWidth: CGFloat(1.2)))
    }
}
