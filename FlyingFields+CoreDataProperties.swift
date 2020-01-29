//
//  FlyingFields+CoreDataProperties.swift
//  JAFO-SwiftUI
//
//  Created by David Mcqueeney on 1/28/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//
//

import Foundation
import CoreData


extension FlyingFields {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<FlyingFields> {
        return NSFetchRequest<FlyingFields>(entityName: "FlyingFields")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var images: [String]?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var longname: String?
    @NSManaged public var shortname: String?
    @NSManaged public var truedir: Double
    @NSManaged public var runwaywidth: Double
    @NSManaged public var runwaylength: Double

}
