//
//  Database.swift
//  Minna
//
//  Created by Taylor Lineman on 6/12/26.
//

import SwiftData
import Foundation

@MainActor
class UserDataDatabase: Database {
    static let shared: UserDataDatabase = UserDataDatabase()

    // Swift Data Variables
    var modelContainer: ModelContainer
    var context: ModelContext {
        modelContainer.mainContext
    }
    
    var initializationError: (any Error)?

    init() {
        let modelConfiguration = ModelConfiguration(schema: Schema.openCanMonitorSchema)
        
        do {
            modelContainer = try ModelContainer(
                for: Schema.openCanMonitorSchema,
                migrationPlan: DatabaseMigrationPlan.self,
                configurations: modelConfiguration
            )
        } catch {
            initializationError = error

            do {
                let inMemoryConfig = ModelConfiguration(schema: Schema.openCanMonitorSchema, isStoredInMemoryOnly: true)
                modelContainer = try ModelContainer(
                    for: Schema.openCanMonitorSchema,
                    migrationPlan: DatabaseMigrationPlan.self,
                    configurations: inMemoryConfig
                )
            } catch {
                // In-memory container is a last resort with no migration plan or disk I/O,
                // so failure here indicates a schema-level programmer error rather than a
                // recoverable runtime condition.
                fatalError("Failed to initialize in-memory fallback container: \(error)")
            }
        }
    }
}
