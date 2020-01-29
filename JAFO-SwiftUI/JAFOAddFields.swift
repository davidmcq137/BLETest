//
//  NewField.swift
//  GenTest
//
//  Created by David Mcqueeney on 1/27/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import Foundation
import SwiftUI
import KeychainSwift

struct JAFOAddFieldx: View {
    var body: some View {
        Text("Hello JAFO").border(Color.red)
    }
}

struct JAFOAddFields: View {
    @State private var rotateState: Double = 0
    @State private var rwyWidth: Double = 20
    @State private var rwyLength: Double = 200
    @State private var rwyXoffset: Double = 0
    @State private var rwyYoffset: Double = 0
    @State private var shortName: String = ""
    @State private var longName: String = ""
    @State private var fieldLat: String = ""
    @State private var fieldLon: String = ""
    @State private var cropImage: [UIImage]!
    @State private var fieldImage: UIImage!
    @State private var gMapsLat: Double = 0.0
    @State private var gMapsLon: Double = 0.0
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var tel: Telem
    
    @FetchRequest(
        entity: FlyingFields.entity(),
        sortDescriptors: []
    ) var fields: FetchedResults<FlyingFields>
    
    var imageWid1500: Double = 1500.0
    var imageHgt1500: Double = 750.0
    var ftPerPixel1500: Double = 3.03881 //google maps ft per pixel at zoom level 17
    
    var initLat: Double = 41.339733  // testing placeholders for lat/lon from CoreLocation service
    var initLon: Double = -74.431618
    
    var body: some View {
        ZStack {
            if self.cropImage != nil {
                GeometryReader { gR in
                    VStack {
                        HStack {
                            Text("Short name:").font(.callout).bold()
                            TextField("Enter short name", text: self.$shortName).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 200, height: 20)
                        }.padding()
                        
                        HStack {
                            Text("Full name:").font(.callout).bold()
                            TextField("Enter full name", text: self.$longName).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 200, height: 20)
                        }.padding()
                        Button(action: {
                            print("save Action")
                            let field = FlyingFields(context: self.moc)
                            field.id = UUID()
                            field.images = [self.shortName + "1500", self.shortName + "3000", self.shortName + "6000"]
                            field.latitude = self.gMapsLat
                            field.longitude = self.gMapsLon
                            field.shortname = self.shortName
                            field.longname = self.longName
                            field.runwaywidth = self.rwyWidth * self.ftPerPixel1500
                            field.runwaylength = self.rwyLength * self.ftPerPixel1500
                            //field.truedir = self.xxx
                            saveFieldFiles(shortName: self.shortName, imageArray: self.cropImage)
                            do {
                                try self.moc.save()
                            } catch {
                                // handle the Core Data error
                            }
                            
                            // now reset back to initial screen to create another field
                            // do we have to zero out all the other @State variables?
                            self.cropImage = nil
                            self.fieldImage = nil
                            
                            // go see if this is the field we should go to now...
                            
                            _ = findField(lat: field.latitude, lon: field.longitude)
                            
                        }){
                            Text("Save JAFO Images")
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(40)
                        .foregroundColor(.yellow)
                        .padding()
                        
                        ZStack {
                            Image(uiImage: self.cropImage[0]).resizable().clipped().aspectRatio(2, contentMode: .fit).border(Color.blue)
                            Text("Cropped \(gR.size.width), \(gR.size.height)")
                            Circle().position(x: 5, y: 5).frame(width:10, height:10).foregroundColor(Color.red)
                            Circle().position(x: 5, y: gR.size.width/8+5).frame(width:10, height:10).foregroundColor(Color.blue)
                            //draw a runway that should overlay the one on the image .. coded for 1500 foot scale
                            Rectangle()
                                .stroke(lineWidth: CGFloat(2))
                                .frame(width: scl(gr: gR.size.width, wid: self.imageWid1500, len: self.rwyLength, fpp: self.ftPerPixel1500), height: scl(gr: gR.size.width/2, wid: self.imageHgt1500, len: self.rwyWidth, fpp: self.ftPerPixel1500))
                                .offset(x:0, y: gR.size.width/8)
                                .foregroundColor(Color.yellow)
                        }
                    }
                }
            } else {
                VStack {
                    HStack {
                        Text("Current Latitude: \(tel.iPadLat)")
                        Text("Current Longitude: \(tel.iPadLon)")
                    }
                    HStack {
                        Text("Latitude:").font(.callout).bold()
                        TextField("Enter latitude", text: self.$fieldLat).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 200, height: 20)
                        
                        Text("Longitude:").font(.callout).bold()
                        TextField("Enter Longitude", text: self.$fieldLon).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 200, height: 20)
                    }.padding()
                    if fieldImage != nil {
                        ZStack (alignment: .bottom){
                            ZStack {
                                Image(uiImage: self.$fieldImage.wrappedValue!)
                                    .clipShape(Circle())
                                    .rotationEffect(Angle(degrees: self.rotateState))
                                    .gesture(RotationGesture()
                                        .onChanged { value in
                                            self.rotateState = value.degrees
                                        }
                                )
                                Circle().position(x: 5, y: 5).frame(width:10, height:10).foregroundColor(Color.red)
                                Rectangle()
                                    .stroke(lineWidth: CGFloat(1))
                                    .offset(x: CGFloat($rwyXoffset.wrappedValue), y: CGFloat($rwyYoffset.wrappedValue))
                                    .frame(width: CGFloat($rwyLength.wrappedValue), height: CGFloat($rwyWidth.wrappedValue))
                                    .foregroundColor(Color.yellow)
                                Rectangle()
                                    .stroke(lineWidth: CGFloat(2))
                                    .offset(x: CGFloat(0.0 + $rwyXoffset.wrappedValue), y: CGFloat(-(imageHgt1500/ftPerPixel1500)/4 + $rwyYoffset.wrappedValue))
                                    .frame(width: CGFloat(imageWid1500/ftPerPixel1500), height: CGFloat(imageHgt1500/ftPerPixel1500))
                                    .foregroundColor(Color.yellow)
                            }
                            VStack {
                                Text("Rot: \(Double($rotateState.wrappedValue), specifier: "%.2f"), Wid: \(ftPerPixel1500 * Double($rwyWidth.wrappedValue), specifier: "%.2f"), Len: \(ftPerPixel1500*Double($rwyLength.wrappedValue),specifier: "%.2f")").foregroundColor(Color.yellow)
                                Text("Xoff: \(ftPerPixel1500 * Double($rwyXoffset.wrappedValue),specifier: "%.2f"), Yoff: \(ftPerPixel1500 * Double($rwyYoffset.wrappedValue),specifier: "%.2f")").foregroundColor(Color.yellow).padding(.bottom, 40)
                            }
                        }
                        HStack {
                            VStack {
                                Slider(value: $rwyYoffset, in: -100...100, step: 1).frame(width: 150, height:40).padding()
                                Text("Runway Y offset")
                            }
                            VStack {
                                Slider(value: $rwyXoffset, in: -100...100, step: 1).frame(width: 150, height: 40).padding()
                                Text("Runway X offset")
                            }
                            VStack {
                                Slider(value: $rwyLength, in: 0...700, step: 2).frame(width: 150, height: 40).padding()
                                Text("Runway Length")
                            }
                            VStack {
                                Slider(value: $rwyWidth, in: 0...100, step: 1).frame(width: 150, height: 40).padding()
                                Text("Runway Width")
                            }
                        }
                    }
                    HStack {
                        Button(action: {
                            print("use current latlon")
                            self.fieldLat = String(self.tel.iPadLat)
                            self.fieldLon = String(self.tel.iPadLon)
                        }){
                            Text("Use current lat/lon")
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(40)
                        .foregroundColor(.yellow)
                        .padding()
                        
                        Button(action: {
                            print("getting image")
                            if self.fieldLat != "" && self.fieldLon != "" {
                                self.gMapsLat = Double(self.fieldLat) ?? 0.0
                                self.gMapsLon = Double(self.fieldLon) ?? 0.0
                                if self.gMapsLat != 0.0 && self.gMapsLon != 0.0 {
                                    print("calling google maps with lat: \(self.gMapsLat), lon: \(self.gMapsLon), zoom: 17")
                                    self.fieldImage = googleMapImage(lat: self.gMapsLat, lon: self.gMapsLon, zoom: 17)
                                    print("back from google maps")
                                } else {
                                    print("bad lat or lon")
                                }
                            } else {
                                print("lat or lon fields blank?")
                            }
                        }) {
                            Text("Get Google Maps Image")
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(40)
                        .foregroundColor(.yellow)
                        .padding()
                        
                        
                        Button(action: {
                            //recompute lat,lon for center of runway, re-request image at those coords
                            let rotR = self.rotateState * Double.pi / 180.0
                            let rE = 21220539.7
                            let dx = self.ftPerPixel1500 * Double(self.rwyXoffset)
                            let dy = -self.ftPerPixel1500 * Double(self.rwyYoffset)
                            //compute runway center point in original image coords
                            let rdx = dx * cos(rotR) - dy * sin(rotR)
                            let rdy = dx * sin(rotR) + dy * cos(rotR)
                            //translate lat lon to center of runway
                            let dlon = (180.0 / Double.pi) * rdx / (rE * cos(self.gMapsLat * Double.pi / 180))
                            let dlat = (180.0 / Double.pi) * rdy / rE
                            //offset now zero since lat lon point at center of runway
                            self.rwyXoffset = 0.0
                            self.rwyYoffset = 0.0
                            self.gMapsLat = self.gMapsLat + dlat
                            self.gMapsLon = self.gMapsLon + dlon
                            print("Calling saveFieldImages")
                            self.cropImage = createFieldImages(rotation: self.rotateState, Lat: self.gMapsLat, Lon: self.gMapsLon, rLen: self.rwyLength, rWid: self.rwyWidth)
                            print("back from sFI")
                        }) {
                            Text("Create cropped/rotated image")
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(40)
                                .foregroundColor(.yellow)
                                .padding()
                        }
                    }
                }
            }
        }
    }
}

func saveFieldFiles(shortName: String, imageArray: [UIImage]) {
    
    let imageName: [String] = ["1500", "3000", "6000"]
        
    for img in 0 ..< 3 {
        if let data = imageArray[img].pngData() {
            let PC = shortName + imageName[img] + ".png"
            let filename = getDocumentsDirectory().appendingPathComponent(PC)
            print("writing: \(PC)")
            try? data.write(to: filename)
            print("written", filename)
        }
    }
    return
}

func createFieldImages(rotation: Double, Lat: Double, Lon: Double, rLen: Double, rWid: Double) -> [UIImage] {
    
    let imageWid: [Double] = [1500.0, 3000.0, 6000.0]
    let imageHgt: [Double] = [750.0, 1500.0, 3000.0]
    let ftPerPixel: [Double] = [3.03881, 6.07763, 12,1553]
    let zoom: [Int] = [17, 16, 15]
    var cropImage: UIImage
    var fieldImage: UIImage
    var returnImage: [UIImage] = [UIImage(systemName: "airplane")!, UIImage(systemName: "airplane")!, UIImage(systemName: "airplane")!]
    var wid: CGFloat
    var hgt: CGFloat

    for img in 0 ..< 3 {
        fieldImage = googleMapImage(lat: Lat, lon: Lon, zoom: zoom[img])
        cropImage = rotateImage(image: fieldImage, angle: CGFloat(rotation * Double.pi / 180.0 + Double.pi), flipVertical: CGFloat(1), flipHorizontal: CGFloat(1))!
        wid = cropImage.size.width
        hgt = cropImage.size.height
        print("w/h:", wid, hgt)
        cropImage = crop(image: cropImage, cropRect: CGRect(x: Double(wid)/2 - (imageWid[img]/2)/ftPerPixel[img] , y: Double(hgt)/2 - (3/4)*imageHgt[img]/ftPerPixel[img], width: imageWid[img]/ftPerPixel[img], height: imageHgt[img]/ftPerPixel[img]))!
        wid = cropImage.size.width
        hgt = cropImage.size.height
        print("w/h:", wid, hgt)
        cropImage = resizeImage(image: cropImage, targetSize: CGSize(width: CGFloat(2048), height: CGFloat(1024)))!
        cropImage = drawRunwayOnImage(image: cropImage, rlen: CGFloat(rLen * ftPerPixel[0]), rwid: CGFloat(rWid * ftPerPixel[0]), imwid: CGFloat(imageWid[img]), imhgt: CGFloat(imageHgt[img]))
        returnImage[img] = cropImage
    }
     return returnImage
}

func googleMapImage(lat: Double, lon: Double, zoom: Int ) -> UIImage {
    
    let keychain = KeychainSwift()
    
    //keychain.set("API Key Goes Here", forKey: "GoogleMaps")
    
    var GoogleMaps: String = ""
    if let GoogleMapsAPIKey = keychain.get("GoogleMaps") {
        print("got API key: \(GoogleMapsAPIKey)")
        GoogleMaps = GoogleMapsAPIKey
    } else {
        print("error .. no API key")
    }
    
    let imageUrlString = "https://maps.googleapis.com/maps/api/staticmap?key=" + GoogleMaps + "&size=2048x2048&center=\(lat)%2C\(lon)&maptype=satellite&zoom=\(zoom)"
    
    let imageUrl = URL(string: imageUrlString)!
    let imageData = try! Data(contentsOf: imageUrl)
    let lit: UIImage = UIImage(systemName: "airplane")!
    
    return UIImage(data: imageData) ?? lit
}

func scl(gr: CGFloat, wid: Double, len: Double, fpp: Double) -> CGFloat {
    print("scl: gr, wid, len, fpp:", gr, wid, len, fpp)
    print("scl: returning:", CGFloat(fpp) * CGFloat(len) * gr / CGFloat(wid))
    return CGFloat(fpp) * CGFloat(len) * gr / CGFloat(wid)
}

func crop(image:UIImage, cropRect:CGRect) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(cropRect.size, false, image.scale)
    let origin = CGPoint(x: cropRect.origin.x * CGFloat(-1), y: cropRect.origin.y * CGFloat(-1))
    image.draw(at: origin)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext();
    
    return result
}

func rotateImage(image:UIImage, angle:CGFloat, flipVertical:CGFloat, flipHorizontal:CGFloat) -> UIImage? {
    let ciImage = CIImage(image: image)
    
    let filter = CIFilter(name: "CIAffineTransform")
    filter?.setValue(ciImage, forKey: kCIInputImageKey)
    filter?.setDefaults()
    
    let newAngle = angle * CGFloat(-1)
    
    var transform = CATransform3DIdentity
    transform = CATransform3DRotate(transform, CGFloat(newAngle), 0, 0, 1)
    transform = CATransform3DRotate(transform, CGFloat(Double(flipVertical) * Double.pi), 0, 1, 0)
    transform = CATransform3DRotate(transform, CGFloat(Double(flipHorizontal) * Double.pi), 1, 0, 0)
    
    let affineTransform = CATransform3DGetAffineTransform(transform)
    
    filter?.setValue(NSValue(cgAffineTransform: affineTransform), forKey: "inputTransform")
    
    let contex = CIContext(options: [CIContextOption.useSoftwareRenderer:true])
    
    let outputImage = filter?.outputImage
    let cgImage = contex.createCGImage(outputImage!, from: (outputImage?.extent)!)
    
    let result = UIImage(cgImage: cgImage!)
    return result
}


func resizeImage(image:UIImage, targetSize:CGSize) -> UIImage? {
     let originalSize = image.size
       
     let widthRatio = targetSize.width / originalSize.width
     let heightRatio = targetSize.height / originalSize.height
 
     let ratio = min(widthRatio, heightRatio)
       
     let newSize = CGSize(width: originalSize.width * ratio, height: originalSize.height * ratio)
       
     // preparing rect for new image size
     let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
       
     // Actually do the resizing to the rect using the ImageContext stuff
     UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
     image.draw(in: rect)
       
     let newImage = UIGraphicsGetImageFromCurrentImageContext()
     UIGraphicsEndImageContext()
       
     return newImage
}

func drawRunwayOnImage(image: UIImage, rlen: CGFloat, rwid: CGFloat, imwid: CGFloat, imhgt: CGFloat) -> UIImage {
    let imageSize = image.size
    let scale: CGFloat = 0
    
    let rwidPix = imageSize.height * rwid / imhgt
    let rlenPix = imageSize.width * rlen / imwid
    
    print("image size.width, image size.heigh", imageSize.width, imageSize.height)
    print("rwidPix, rlenPix, rlen, rwid, imwid, imhgt", rwidPix, rlenPix, rlen, rwid, imwid, imhgt)
    
    UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)

    image.draw(at: CGPoint.zero)
    let rectangle = CGRect(x: imageSize.width/2 - rlenPix/2, y: (3*imageSize.height/4) - rwidPix/2, width: rlenPix, height: rwidPix)
    //let rectangle = CGRect(x: 0, y: rwidPix/2, width: rlenPix, height: rwidPix)
    UIColor.yellow.setStroke()
    UIRectFrame(rectangle)
    //UIColor.yellow.setFill()
    //UIRectFill(rectangle)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

//func getDocumentsDirectory() -> URL {
//    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//    return paths[0]
//}



