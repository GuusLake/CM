//
//  GroupData+CoreDataProperties.swift
//  Vocabul-R
//
//  Created by Guillermo on 14/05/2022.
//
//

import Foundation
import CoreData


extension GroupData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupData> {
        return NSFetchRequest<GroupData>(entityName: "GroupData")
    }

    @NSManaged public var cleared_words: Int16
    @NSManaged public var index_group: Int16
    @NSManaged public var mean_level: Int16
    @NSManaged public var topic: TopicData?
    @NSManaged public var word: NSSet?

}

// MARK: Generated accessors for word
extension GroupData {

    @objc(addWordObject:)
    @NSManaged public func addToWord(_ value: Word)

    @objc(removeWordObject:)
    @NSManaged public func removeFromWord(_ value: Word)

    @objc(addWord:)
    @NSManaged public func addToWord(_ values: NSSet)

    @objc(removeWord:)
    @NSManaged public func removeFromWord(_ values: NSSet)

}

extension GroupData : Identifiable {

}
