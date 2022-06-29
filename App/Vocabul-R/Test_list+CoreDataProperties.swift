//
//  Test_list+CoreDataProperties.swift
//  Vocabul-R
//
//  Created by Guillermo on 15/06/2022.
//
//

import Foundation
import CoreData


extension Test_list {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Test_list> {
        return NSFetchRequest<Test_list>(entityName: "Test_list")
    }

    @NSManaged public var test_list: String?
    @NSManaged public var word: NSSet?

}

// MARK: Generated accessors for word
extension Test_list {

    @objc(addWordObject:)
    @NSManaged public func addToWord(_ value: Word)

    @objc(removeWordObject:)
    @NSManaged public func removeFromWord(_ value: Word)

    @objc(addWord:)
    @NSManaged public func addToWord(_ values: NSSet)

    @objc(removeWord:)
    @NSManaged public func removeFromWord(_ values: NSSet)

}

extension Test_list : Identifiable {

}
