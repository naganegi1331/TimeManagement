//
//  ActivityLog.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//

import Foundation
import SwiftData

// 活動記録モデル
@Model
final class ActivityLog {
    var startTime: Date
    var endTime: Date
    var memo: String
    
    // Enumを介して関連付け
    var categoryRawValue: String
    var priorityRawValue: String
    
    var category: ActivityCategory {
        get {
            ActivityCategory(rawValue: categoryRawValue) ?? .life
        }
        set {
            categoryRawValue = newValue.rawValue
        }
    }
    
    var priority: PriorityMatrix {
        get {
            PriorityMatrix(rawValue: priorityRawValue) ?? .notImportantNotUrgent
        }
        set {
            priorityRawValue = newValue.rawValue
        }
    }
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var durationInMinutes: Int {
        Int(duration / 60)
    }
    
    init(startTime: Date, endTime: Date, memo: String, category: ActivityCategory, priority: PriorityMatrix) {
        self.startTime = startTime
        self.endTime = endTime
        self.memo = memo
        self.categoryRawValue = category.rawValue
        self.priorityRawValue = priority.rawValue
    }
} 