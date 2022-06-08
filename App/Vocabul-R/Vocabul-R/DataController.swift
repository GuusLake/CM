//
//  Persistent.swift
//  Vocabul-R
//
//  Created by Guillermo on 27/04/2022.
//

import Foundation
import CoreData


class DataController: ObservableObject {
    let container = NSPersistentCloudKitContainer(name: "vocabulR")

    init() {
        container.loadPersistentStores { description, error in
                if let error = error {
                    print("CoreData failed to load: \(error.localizedDescription)")
                }
        }
        container.viewContext.retainsRegisteredObjects = true

    }
}

