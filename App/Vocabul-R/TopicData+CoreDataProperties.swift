//
//  TopicData+CoreDataProperties.swift
//  Vocabul-R
//
//  Created by Guillermo on 15/06/2022.
//
//

import Foundation
import CoreData


extension TopicData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TopicData> {
        return NSFetchRequest<TopicData>(entityName: "TopicData")
    }

    @NSManaged public var activated: Bool
    @NSManaged public var activationLevel: Int16
    @NSManaged public var current_level: Int16
    @NSManaged public var finished: Bool
    @NSManaged public var last_opened_group: Int16
    @NSManaged public var name: String?
    @NSManaged public var group: NSSet?

}

// MARK: Generated accessors for group
extension TopicData {

    @objc(addGroupObject:)
    @NSManaged public func addToGroup(_ value: GroupData)

    @objc(removeGroupObject:)
    @NSManaged public func removeFromGroup(_ value: GroupData)

    @objc(addGroup:)
    @NSManaged public func addToGroup(_ values: NSSet)

    @objc(removeGroup:)
    @NSManaged public func removeFromGroup(_ values: NSSet)

}

extension TopicData : Identifiable {

}
