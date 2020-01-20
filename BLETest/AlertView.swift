//
//  AlertView.swift
//  BLETest
//
//  Created by David Mcqueeney on 1/19/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import SwiftUI

struct AlertView: View {
    
    @State private var showingAlert = true
    @EnvironmentObject var tel: Telem
    
    var body: some View {
        Button(action: {
            self.showingAlert = true
            self.tel.BLEUserData = true // only do this once
        }) {
            Text("")
            //   .font(.title)
            //  .foregroundColor(Color.white)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("NO BLE UART Assigned"), message: Text("Go to BLE Devices Tab"), primaryButton: .default(Text("OK")), secondaryButton: .destructive(Text("Cancel")))
        }
    }
}
