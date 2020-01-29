//
//  ContentView.swift
//  BLETest
//
//  Created by David Mcqueeney on 1/11/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import SwiftUI
import Combine


struct ContentView: View {
    @State private var selection = 1

    //init() {
    //    UITabBar.appearance().backgroundColor = UIColor.black
    //}
    
    var body: some View {
        TabView (selection: $selection) {
            JAFOMain()
                .tabItem {
                    VStack {
                        Image(systemName: "1.circle")
                        Text("Main")
                    }
            }.tag(1)
            JAFOMapOnly()
                .tabItem {
                    VStack {
                        Image(systemName: "2.circle")
                        Text("Field Map")
                    }
            }.tag(2)
            JAFODeviceList()
                .tabItem {
                    VStack {
                        Image(systemName: "3.circle")
                        Text("BLE Devices")
                    }
            }.tag(3)
            JAFOAddFields()
                .tabItem {
                    VStack {
                        Image(systemName: "4.circle")
                        Text("New Fields")
                    }
            }.tag(4)
            JAFOListFields()
                .tabItem {
                    VStack {
                        Image(systemName: "5.circle")
                        Text("List Fields")
                    }
            }.tag(5)
            
        }.background(SwiftUI.Color.black).edgesIgnoringSafeArea(.all)
    }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
