//
//  JAFOListFields.swift
//  JAFO-SwiftUI
//
//  Created by David Mcqueeney on 1/27/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

var nlat: Double = 40

struct JAFOListFields: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(
        entity: FlyingFields.entity(),
        sortDescriptors: []
    ) var fields: FetchedResults<FlyingFields>


    var body: some View {
        VStack{
            Text("Flying Fields").font(.largeTitle)
            //NavigationView {
                List {
                    ForEach(fields, id: \.id) { field in
                        HStack {
                            Text(field.longname ?? "unk")
                            Text("(" + (field.shortname ?? "unk") + ")")
                            Spacer()
                            Text("Td: \(field.truedir)")
                            Text("Lon: \(field.longitude)")
                            Text("Lat: \(field.latitude)")
                            //Text("\(field.images?[0] ?? "No image").png")
                        }
                    }.onDelete(perform: removeFields)
                }//.navigationBarItems(trailing: EditButton())
            //}
            /*
            Button(action: {
                let field = FlyingFields(context: self.moc)
                field.id = UUID()
                field.latitude = self.nextLat()
                field.longitude = self.nextLat()
                field.shortname = "BDS"
                field.longname = "Black Dirt Squadron"
                field.images = ["1500", "3000", "6000"]
                do {
                    try self.moc.save()
                } catch {
                    // handle the Core Data error
                }
                
            }) {
                Text("Add a Field")
            }
            */
        }
    }
    func nextLat()-> Double {
        nlat = nlat + 10
        return nlat
    }
    func removeFields(at offsets: IndexSet) {
        for index in offsets {
            let field = fields[index]
            moc.delete(field)
        }
        do {
            try self.moc.save()
        } catch {
            // handle the Core Data error
        }
    }
}

