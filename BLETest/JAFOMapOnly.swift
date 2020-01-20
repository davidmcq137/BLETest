//
//  JAFOMapOnly.swift
//  BLETest
//
//  Created by David Mcqueeney on 1/19/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//


import SwiftUI

struct JAFOMapOnly: View {
    
    @EnvironmentObject var tel: Telem
    
    var body: some View {
        VStack{
            FieldMap()//.border(Color.blue)
        }.background(SwiftUI.Color.black).edgesIgnoringSafeArea(.top)
    }
}
