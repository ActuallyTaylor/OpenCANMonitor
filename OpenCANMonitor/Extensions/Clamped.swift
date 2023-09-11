//
//  Comparable.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/8/23.
//

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
