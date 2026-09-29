//
//  Schema.swift
//  OpenCANMonitor
//
//  Created by Taylor Lineman on 9/28/26.
//

import SwiftData

typealias CANTransmitMessage = SchemaV1.CANTransmitMessage

extension Schema {
    static let openCanMonitorSchema: Schema = Schema([
        SchemaV1.CANTransmitMessage.self
    ])
}

enum DatabaseMigrationPlan: SchemaMigrationPlan {
    static let schemas: [any VersionedSchema.Type] = [SchemaV1.self]
    static let stages: [MigrationStage] = []
}

enum SchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    
    static let models: [any PersistentModel.Type] = [
        SchemaV1.CANTransmitMessage.self
    ]
}
