//
//  FlyingFields.swift
//  BLETest
//
//  Created by David Mcqueeney on 1/12/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import Foundation
import SwiftUI


struct ActiveField {
    var images: [String] = []
    var imageIdx: Int = -1
    var latitude: Double = 0
    var longitude: Double = 0
    var shortname: String = "(unk)"
    var longname:String = ""
    var truedir: Double = 0
    var runwaywidth: Double = 0
    var runwaylength: Double = 0
}

var activeField = ActiveField()

//var currentField: field?
//var currentImage: String?
//var currentImageIndex: Int?


/*
struct flyingFields: Decodable {
    let fields: [field]
}

struct field: Decodable {
    let name: String
    let shortname: String
    let runway: rwy
    let POI: [POIPoint]?
    let images: [image]
}

struct rwy: Decodable {
    let lat: Double
    let long: Double
    let trueDir: Double
    let length: Double
    let width: Double
}

struct POIPoint: Decodable {
    let lat: Double
    let long: Double
}

struct image: Decodable {
    let filename: String
    let xrange: Double
}

var heading: Double = 0.0
var FF: flyingFields!
var selectedfilename: String!
*/

//var iPadLat: Double = 0
//var iPadLon: Double = 0

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func findField(lat: Double, lon: Double) -> Bool{
    let request = FlyingFields.createFetchRequest()
    do {
        let fields = try container.viewContext.fetch(request)
        print("Got \(fields.count) fields from fetch request")
        activeField.imageIdx = -1 // set to -1 to indicate no active field
        for f in fields {
            print(f.shortname!, f.longname!, f.latitude, f.longitude)
            if abs(lon - f.longitude) < 1/60 && abs(lat - f.latitude) < 1/60 {
                print("found a lat/lon match")
                activeField.images = f.images ?? []
                activeField.latitude = f.latitude
                activeField.longitude = f.longitude
                activeField.shortname = f.shortname ?? "()"
                activeField.longname = f.longname ?? "Unk"
                activeField.truedir = f.truedir
                activeField.imageIdx = 0 // index 0 is the 1500' image, index 1 is 3000', index 2 is 6000', view will load file when imageIdx changes
                activeField.runwaywidth = f.runwaywidth
                activeField.runwaylength = f.runwaylength
            }
        }
    } catch {
        print("Fetch failed")
        return false

    }
    return true // if never found a match, imageIdx will be -1
}

/*
 
 
 func findField(lat: Double, lon: Double) -> field? {
     
     let jsonName =  "Fields.jsn"
     let jsonURL =  getDocumentsDirectory().appendingPathComponent(jsonName)
     let jsonPath = jsonURL.path
     
     let teststr="this is a test string"
     let testfilename = getDocumentsDirectory().appendingPathComponent("test.file")
     do {
         try teststr.write(to: testfilename, atomically: true, encoding: String.Encoding.utf8)
         print("written")
     } catch {
         print("bad write")
     }
     
     //print("jsonPath: \(jsonPath)")
     //print("jsonURL: \(jsonURL)")
     //print("jsn exists: \(FileManager.default.fileExists(atPath: jsonPath))")
     
     guard
         FileManager.default.fileExists(atPath: jsonPath),
         let jsonData: Data =  try? Data(contentsOf: jsonURL) else {
             print("no data")
             return nil
     }
     
     var selectedField: Int?
     
     do {
         let flyingfields = try
             JSONDecoder().decode(flyingFields.self, from: jsonData)
         FF = flyingfields
         //print("***********starting loop over flyingfields *************")
         for i in 0 ..< flyingfields.fields.count {
             //print("field\(i+1) name: \(flyingfields.fields[i].name)")
             //print("field\(i+1) shortname: \(flyingfields.fields[i].shortname)")
             //for j in 0 ..< flyingfields.fields[i].images.count {
             //    //print("image\(j+1) filename: \(flyingfields.fields[i].images[j].filename)")
             //    //print("image\(j+1) xrange:: \(flyingfields.fields[i].images[j].xrange)")
             //}
             //if flyingfields.fields[i].POI?[0].lat != nil {
             //     for k in 0 ..< flyingfields.fields[i].POI!.count {
             //print("POI\(k+1) lat: \(flyingfields.fields[i].POI![k].lat), long: \(flyingfields.fields[i].POI![k].long)")
             //    }
             //} else {
             //    print("no POIs")
             //}
             if abs(flyingfields.fields[i].runway.lat - lat) < 1/60 || abs(flyingfields.fields[i].runway.long - lon) < 1/60 {
                 selectedField = i
             }
             //print("Runway.lat: \(flyingfields.fields[i].runway.lat)")
             //print("Runway.long: \(flyingfields.fields[i].runway.long)")
             //print("Runway.trueDir: \(flyingfields.fields[i].runway.trueDir)")
             //print("Runway.length: \(flyingfields.fields[i].runway.length)")
             //print("Runway.width: \(flyingfields.fields[i].runway.width)")
             //print("************************")
         }
     } catch let jsonErr {
         print("error serializing", jsonErr)
     }
     
     if selectedField != nil {
         Re = 21220539.7 // radius of earth: 6371 km * 1000 m/km * 3.28084 ft/m * 0.985 fudge factor
         lat0 = FF.fields[selectedField!].runway.lat
         lon0 = FF.fields[selectedField!].runway.long
         coslat0 = cos(lat0 * .pi / 180.0)
         td = FF.fields[selectedField!].runway.trueDir
         //print("sfn: \(FF.fields[selectedField!].images[0].filename)")
         return FF.fields[selectedField!]
     } else {
         print("No selected field")
         return nil
     }
     

     
 }

 
 
 */
