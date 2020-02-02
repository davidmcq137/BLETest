//
//  fieldAnnotation.swift
//  BLETest
//
//  Created by David Mcqueeney on 1/13/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import SwiftUI
import Foundation


struct fieldAnnotation: View {
    private let idx: Int?
    
    init(idx: Int?) {
        self.idx = idx
    }
    
    let xrange: [Int] = [1500, 3000, 6000]
    var body: some View {
        var annot: String
        if idx! >= 0 {
            let xr = String(format: "%d", xrange[idx!])
            annot = activeField.longname + " (" + activeField.shortname + ")" + "\r\n"
            annot = annot + "File: " + activeField.images[idx!] + " "
            annot = annot + "  Scale: " + xr +  " ft"
        } else {
            annot = "No Field Selected"
        }
        
        return
            VStack {
                Text(annot).multilineTextAlignment(.center)
                    .font(.body)
                    .foregroundColor(Color.yellow)
                Image(systemName: "location.north.fill").rotationEffect(Angle(degrees: activeField.truedir)).foregroundColor(Color.yellow).font(.system(size: 25))
        }
    }
}
