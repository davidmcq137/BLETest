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
    private let title: String
    
    init(Val: Double, side: String, title: String) {
        self.Val = Val
        self.side = side
        self.title = title
    }
    
    var body: some View {
        GeometryReader { gR in
            ZStack {
                ForEach(-2...10, id: \.self) {
                    Text(tapeLabeltxt(val: self.Val, index: $0, delta: Delta(val: self.Val), height: gR.size.height, side: self.side))
                        .position(tapeLabelpos(index: $0, delta: Delta(val: self.Val)*Double(gR.size.height)/100, xpos: ofst(side: self.side, width: Double(gR.size.width)), height: gR.size.height))
                        .clipShape(Rectangle())
                        .foregroundColor(Color.yellow)
                        //.font(Font.body.weight(.bold))
                }
                tapeLine().foregroundColor(Color.yellow)
                tapePointer(side: self.side).foregroundColor(Color.yellow)
                Text(self.title).position(x: gR.size.width/2, y: gR.size.height + gR.size.height/330*20).foregroundColor(Color.yellow).font(.headline)
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
        let rat = rect.maxY/rect.maxX
        let size: CGFloat = 10
        var path = Path()
        if side == "Right" {
            path.move(to: CGPoint(x:rect.minX, y:rect.midY - size))
            path.addLine(to: CGPoint(x:rect.minX, y:rect.midY + size))
            path.addLine(to: CGPoint(x:rect.minX + size, y:rect.midY))
            path.addLine(to: CGPoint(x:rect.minX, y:rect.midY - size))
        } else {
            path.move(to: CGPoint(x:rect.maxX-0*size, y:rect.midY - size))
            path.addLine(to: CGPoint(x:rect.maxX-0*size, y:rect.midY + size))
            path.addLine(to: CGPoint(x:rect.maxX - size, y:rect.midY))
            path.addLine(to: CGPoint(x:rect.maxX-0*size, y:rect.midY - size))
        }
        return path
    }
}

struct tapeLine: Shape {
    
    func path(in rect: CGRect) -> Path {
        let rat = rect.maxY/rect.maxX
        var path = Path()
        path.move(to: CGPoint(x:rect.minX, y:rect.maxY))
        path.addLine(to: CGPoint(x:rect.minX, y: 0))
        path.addLine(to: CGPoint(x:rect.maxY/rat, y: 0))
        path.addLine(to: CGPoint(x:rect.maxY/rat, y: rect.maxY))
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

private func ofst(side: String, width: Double) -> Int {
    
    if side == "Right" {
        return Int(45 * width / 70)
    } else {
        return Int(22.5 * width / 70)
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


