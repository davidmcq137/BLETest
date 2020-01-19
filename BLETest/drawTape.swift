//
//  drawTape.swift
//  BLETest
//
//  Created by David Mcqueeney on 1/15/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import SwiftUI
import Combine

struct drawTape: View {

    private let Val: Double
    private let side: String
    
    init(Val: Double, side: String) {
        self.Val = Val
        self.side = side
    }
    
    var body: some View {
        GeometryReader { gR in
            ZStack {
                ForEach(-2...10, id: \.self) {
                    Text(tapeLabeltxt(val: self.Val, index: $0, delta: Delta(val: self.Val), height: gR.size.height, side: self.side))
                        .position(tapeLabelpos(index: $0, delta: Delta(val: self.Val)*Double(gR.size.height)/100, xpos: ofst(side: self.side), height: gR.size.height))
                        .clipShape(Rectangle())
                        .foregroundColor(Color.yellow)
                        //.font(Font.body.weight(.bold))
                }
                tapeLine().foregroundColor(Color.yellow)
                tapePointer(side: self.side).foregroundColor(Color.yellow)
            }
        }
    }
}

struct tapePointer: Shape {
    private let side: String
    init(side: String) {
        self.side = side
    }
    
    func path(in rect: CGRect) -> Path {
        let size: CGFloat = 10
        var path = Path()
        if side == "Right" {
            path.move(to: CGPoint(x:rect.minX, y:rect.midY - size))
            path.addLine(to: CGPoint(x:rect.minX, y:rect.midY + size))
            path.addLine(to: CGPoint(x:rect.minX + size, y:rect.midY))
            path.addLine(to: CGPoint(x:rect.minX, y:rect.midY - size))
        } else {
            path.move(to: CGPoint(x:rect.maxX-size, y:rect.midY - size))
            path.addLine(to: CGPoint(x:rect.maxX-size, y:rect.midY + size))
            path.addLine(to: CGPoint(x:rect.maxX - 2*size, y:rect.midY))
            path.addLine(to: CGPoint(x:rect.maxX-size, y:rect.midY - size))
        }
        return path
    }
}

struct tapeLine: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x:rect.minX, y:rect.maxY))
        path.addLine(to: CGPoint(x:rect.minX, y: 0))
        path.addLine(to: CGPoint(x:rect.maxY/5, y: 0))
        path.addLine(to: CGPoint(x:rect.maxY/5, y: rect.maxY))
        path.addLine(to: CGPoint(x:rect.minX, y: rect.maxY))
        //path.addLine(to: CGPoint(x:rect.minX, y: rect.midY))
        //path.addLine(to: CGPoint(x:rect.maxY/5, y: rect.midY))
        return path.strokedPath(StrokeStyle(lineWidth: CGFloat(2)))
        }
}
    

private func Delta(val: Double) -> Double {
    //print(val, val.truncatingRemainder(dividingBy: 10))
    return val.truncatingRemainder(dividingBy: 10)
}

private func ofst(side: String) -> Int {
    
    if side == "Right" {
        return 44
    } else {
        return 22
    }
}

private func tapeLabeltxt(val: Double, index: Int,  delta: Double, height: CGFloat, side: String) -> String {
    let i: Int = 40 - 10 * index + Int(val - delta + 0.0)
    let s: String
    
    if side == "Right" {
        s = String(format: "%4d \u{2014}", i)
        //s = "\(i)  \u{2014}"
    } else {
        s = String(format:"\u{2014}  %4d", i)
    }
    return s
}

private func tapeLabelpos(index: Int, delta: Double, xpos: Int, height: CGFloat) -> CGPoint {
    let yp: Double
    yp = Double(height) / 10.0 + delta + Double(height) / 10.0 * Double(index)
    let pt: CGPoint = CGPoint(x: xpos, y: Int(yp))
    return pt
}


