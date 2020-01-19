//
//  cometTail.swift
//  BLETest
//
//  Created by David Mcqueeney on 1/17/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import SwiftUI
import Combine

var lat0: Double = 0
var lon0: Double = 0
var Re: Double = 0
var coslat0: Double = 0
var td: Double = 0
var xr: Double = 0
var toXpix: Double = 0
var toYpix: Double = 0
//var sw: Double = 768 // kludge!

let MAXTABLE: Int = 16
let MAXBEZIER: Int = 8

var xp: [Double] = Array(repeating: 0.0, count: MAXTABLE+1)
var yp: [Double] = Array(repeating: 0.0, count: MAXTABLE+1)


var Bxp: [Double]  = Array(repeating: 0.0, count: MAXBEZIER+1)
var Byp: [Double]  = Array(repeating: 0.0, count: MAXBEZIER+1)

func xPix(xd: Double, width: Double) -> CGFloat{
    if currentField == nil || currentImageIndex == nil {
        return CGFloat(0.0)
    }
    let xr = currentField!.images[currentImageIndex!].xrange
    let xp =  width/2 + width * xd / xr
    //print("xd: \(xd), xp:\(xp)")
    return CGFloat(xp)
}


func yPix(yd: Double, height: Double) -> CGFloat {
    if currentField == nil || currentImageIndex == nil {
        return CGFloat(0.0)
    }
    let yr = currentField!.images[currentImageIndex!].xrange / 2
    var yp =  height / 4 + height * yd / yr
    yp = height - yp
    //print("yd: \(yd), yp:\(yp)")
    return CGFloat(yp)
}

struct bezPath: Shape {

    private let idx: Int?
    private let xd: Double
    private let yd: Double
    private let width: Double
    private let height: Double
    
    init(idx: Int?, xd: Double, yd: Double, width: Double, height: Double) {
        self.idx = idx
        self.xd = xd
        self.yd = yd
        self.width = width
        self.height = height
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if idx == nil {
            return path
        }
        
        path.move(to: CGPoint(x: xPix(xd: Bxp[0], width: self.width), y: yPix(yd: Byp[0], height: self.height)))
        //print(self.width, self.height, xPix(xd: Bxp[0], width: self.width), yPix(yd: Byp[0], height: self.height))
        for i in 1 ..< Bxp.count {
            path.addLine(to: CGPoint(x: xPix(xd: Bxp[i], width: self.width), y: yPix(yd: Byp[i], height: self.height)))
        }
        path.addLine(to: CGPoint(x: xPix(xd: xd, width: self.width), y: yPix(yd: yd, height: self.height)))
        return path.strokedPath(StrokeStyle(lineWidth: CGFloat(4)))
    }
}

struct iconT38: Shape {
    
    private let idx: Int?
    private let rotA: Double
    
    init(idx: Int?, rotA: Double) {
        self.idx = idx
        self.rotA = rotA
    }
    

    func path(in rect: CGRect) -> Path {

        let T38x: [Int] = [0,    -6, -20, -20, -4, -4, -12, -12, 0,  12, 12, 4, 4, 20, 20,   6]
        let T38y: [Int] = [-40, -12,   0,   4,  4,  8,  16,  20, 20, 20, 16, 8, 4,  4,  0, -12]
        let T38s: Double = 0.70
        
        var path = Path()
        
        if idx == nil {
            return path
        }
        
        path.move(to: CGPoint(x: Double(rect.midX) + T38s * Double(T38x[0]), y: Double(rect.midY) + T38s * Double(T38y[0])))
        /*
        path.move(to: CGPoint(x: rect.midX, y:rect.midY))
        path.addLine(to: CGPoint(x: rect.midX-20, y:rect.midY))
        path.addLine(to: CGPoint(x: rect.midX+20, y:rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y:rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y:rect.midY-20))
        path.addLine(to: CGPoint(x: rect.midX, y:rect.midY+20))
        */
        for i in 1 ..< T38x.count {
            path.addLine(to: CGPoint(x: Double(rect.midX) + T38s * Double(T38x[i]), y: Double(rect.midY) + T38s * Double(T38y[i])))
        }
        path.addLine(to: CGPoint(x: Double(rect.midX) + T38s * Double(T38x[0]), y: Double(rect.midY) + T38s * Double(T38y[0])))
        path.closeSubpath()
        //return path.strokedPath(StrokeStyle(lineWidth: CGFloat(2))).rotation(.radians(rotA), anchor: .center).path(in: rect)
        return path.rotation(.radians(rotA), anchor: .center).path(in: rect)
    }
}

func fslope(ymult: Int) -> Double {
    
    var xbar = 0.0
    var ybar = 0.0
    var sxy = 0.0
    var sx2 = 0.0
    var theta: Double
    var tt: Double
    
    for i in MAXTABLE-3 ..< MAXTABLE  {
        xbar = xbar + xp[i]
        ybar = ybar + yp[i] * Double(ymult)
    }
    
    xbar = xbar / Double(3)
    ybar = ybar / Double(3)
    
    for i in MAXTABLE-3 ..< MAXTABLE  {
        sxy = sxy + (xp[i] - xbar) * (yp[i] * Double(ymult) - ybar)
        sx2 = sx2 + (xp[i] - xbar) * (xp[i] - xbar)
    }
    
    if sx2 < 1.0E-6 {
        sx2 = 1.0E-6
    }
    
    //slope = sxy/sx2
    
    theta = atan2(sxy, sx2)
    
    
    if xp[MAXTABLE-2] < xp[MAXTABLE-1] {
        //print("to right")
        tt = theta +  Double.pi / 2.0
    } else {
        //print("to left")
        tt = theta + 3.0 * Double.pi / 2.0
    }
    
    return tt
}

func rotateXY (x: Double, y: Double, rotation: Double) -> (Double, Double) {
    let ss = sin(rotation)
    let cs = cos(rotation)
    return (x * cs - y * ss, x * ss + y * cs)
}

func GPStoPixel (lat: Double, lon: Double) -> (Double, Double)  {
    var xpp: Double
    var ypp: Double
    //print("Re, lat0, lon0, xr, toXpix, toYpix: \(Re), \(lat0), \(lon0), \(xr), \(toXpix), \(toYpix)")
    //print("coslat0, td, sw: \(coslat0), \(td), \(sw)")
    var px = Re * (lon-lon0) * coslat0 * Double.pi / 180.0
    var py = Re * (lat-lat0) * Double.pi / 180.0
    
    (px, py) = rotateXY(x: px, y:py, rotation: (td - 270) * Double.pi / 180.0)
    
    px = px + xr / 2.0
    py = py + xr / 8.0
    
    let sw: Double = 768 // hack: screenwidth .. fix with geo reader
    xpp = px * toXpix
    ypp = 64.0 + sw / 2.0 - py * toYpix

    return (xpp, ypp)
}


func GPStoXY (lat: Double, lon: Double) -> (Double, Double)  {
    //print("Re, lat0, lon0, xr, toXpix, toYpix: \(Re), \(lat0), \(lon0), \(xr), \(toXpix), \(toYpix)")
    //print("coslat0, td, sw: \(coslat0), \(td), \(sw)")
    var px = Re * (lon-lon0) * coslat0 * Double.pi / 180.0
    var py = Re * (lat-lat0) * Double.pi / 180.0
    
    (px, py) = rotateXY(x: px, y:py, rotation: (td - 270) * Double.pi / 180.0)
    
    return (px, py)
}

func GPStoX (lat: Double, lon: Double) -> Double  {
    //print("Re, lat0, lon0, xr, toXpix, toYpix: \(Re), \(lat0), \(lon0), \(xr), \(toXpix), \(toYpix)")
    //print("coslat0, td, sw: \(coslat0), \(td), \(sw)")
    var px = Re * (lon-lon0) * coslat0 * Double.pi / 180.0
    var py = Re * (lat-lat0) * Double.pi / 180.0
    
    (px, py) = rotateXY(x: px, y:py, rotation: (td - 270) * Double.pi / 180.0)
    
    return px
}

func GPStoY (lat: Double, lon: Double) -> Double  {
    //print("Re, lat0, lon0, xr, toXpix, toYpix: \(Re), \(lat0), \(lon0), \(xr), \(toXpix), \(toYpix)")
    //print("coslat0, td, sw: \(coslat0), \(td), \(sw)")
    var px = Re * (lon-lon0) * coslat0 * Double.pi / 180.0
    var py = Re * (lat-lat0) * Double.pi / 180.0
    
    (px, py) = rotateXY(x: px, y:py, rotation: (td - 270) * Double.pi / 180.0)
    
    return py
}
func binom(n: Int, kk: Int) -> Double {
    
    // todo: put back memory function that was in the lua code
    //
    // compute binomial coefficients to then compute the Bernstein polynomials for Bezier
    // n will always be MAXTABLE-1 once past initialization
    // as we compute for each k, remember in a table and save
    // for MAXTABLE = 5, there are only ever 3 values needed in steady state: (4,0), (4,1), (4,2)
    
    var k: Int = 0
    
    k = kk
    
    if k > n {
        print("binom error k>n")
        return 0
    } // error .. let caller die
    
    if k > n / 2 {
        k = n - k // because (n k) = (n n-k) by symmetry
    }
    
    // if (n == MAXTABLE-1) and binomC[k] then return binomC[k] end
    
    var numer: Double = 1
    var denom: Double = 1
    
    if k >= 1 {
        for i in  1 ... k {
            numer = numer * Double( n - i + 1 )
            denom = denom * Double(i)
        }
    }
    //print("n, k, num, den, coeff: \(n), \(k), \(numer), \(denom), \(numer / denom)")
    if n == MAXTABLE-1 {
        //binomC[k] = numer / denom
        return  numer / denom
    } else {
        return numer / denom
    }
}

func computeBezier(numT: Int) {
    
    // compute Bezier curve points using control points in xtable[], ytable[]
    // with numT points over the [0,1] interval
    
    var px: Double = 0
    var py: Double = 0
    var t: Double = 0
    var bn: Double = 0
    var ti: Double = 0
    var oti: Double = 0
    var n: Int = 0
    
    n = MAXTABLE-1
    
    for j in 0 ... numT {
        t = Double(j) / Double(numT)
        px = 0
        py = 0
        ti = 1 // first loop t^i = 0^0 which lua says is 1
        for i in 0 ... n {
            //print("n, i, t, oti: \(n), \(i), \(t), \(oti)")
            oti = pow((1.0-t), Double(n-i))
            //print("n, i, t, oti: \(n), \(i), \(t), \(oti)")

            bn = binom(n: n, kk: i) * ti * oti
            px = px + bn * xp[i]
            py = py + bn * yp[i]
            ti = ti * t
        }
        //print("j, bp: \(j), \(px), \(py)")
        
        Bxp[j] = px
        Byp[j] = py
        
        //bezierPath[j]  = {x=px,   y=py}
        
    }
}
