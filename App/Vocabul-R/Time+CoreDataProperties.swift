//
//  Time+CoreDataProperties.swift
//  Vocabul-R
//
//  Created by Guillermo on 15/06/2022.
//
//

import Foundation
import CoreData


extension Time {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Time> {
        return NSFetchRequest<Time>(entityName: "Time")
    }

    @NSManaged public var time: Date?
    @NSManaged public var word: Word?

}

extension Time : Identifiable {

}
