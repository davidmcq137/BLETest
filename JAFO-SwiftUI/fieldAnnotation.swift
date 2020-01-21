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
    
    var body: some View {
        var annot: String
        if idx != nil {
            let xr = String(format: "%d", Int(currentField!.images[idx!].xrange))
            annot = currentField!.name + " (" + currentField!.shortname + ")" + "\r\n"
            annot = annot + "File: " + currentField!.images[idx!].filename + " "
            annot = annot + "  Scale: " + xr +  " ft"
        } else {
            annot = "No Field Selected"
        }
        
        return Text(annot).multilineTextAlignment(.center)
            .font(.body)
            .foregroundColor(Color.yellow)
    }
}
