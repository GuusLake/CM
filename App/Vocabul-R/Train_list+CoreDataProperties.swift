//
//  Train_list+CoreDataProperties.swift
//  Vocabul-R
//
//  Created by Guillermo on 15/06/2022.
//
//

import Foundation
import CoreData


extension Train_list {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Train_list> {
        return NSFetchRequest<Train_list>(entityName: "Train_list")
    }

    @NSManaged public var train_list: String?
    @NSManaged public var word: NSSet?

}

// MARK: Generated accessors for word
extension Train_list {

    @objc(addWordObject:)
    @NSManaged public func addToWord(_ value: Word)

    @objc(removeWordObject:)
    @NSManaged public func removeFromWord(_ value: Word)

    @objc(addWord:)
    @NSManaged public func addToWord(_ values: NSSet)

    @objc(removeWord:)
    @NSManaged public func removeFromWord(_ values: NSSet)

}

extension Train_list : Identifiable {

}
