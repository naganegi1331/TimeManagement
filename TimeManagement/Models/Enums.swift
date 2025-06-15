//
//  Enums.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//

import Foundation

// カテゴリ（コードで管理するためEnumが適している）
enum ActivityCategory: String, Codable, CaseIterable {
    case work = "仕事"
    case learning = "学習"
    case exercise = "運動"
    case hobby = "趣味"
    case life = "生活"
    case sleep = "睡眠"
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .learning: return "book.fill"
        case .exercise: return "figure.run"
        case .hobby: return "gamecontroller.fill"
        case .life: return "house.fill"
        case .sleep: return "bed.double.fill"
        }
    }
    
    var color: String {
        switch self {
        case .work: return "blue"
        case .learning: return "green"
        case .exercise: return "orange"
        case .hobby: return "purple"
        case .life: return "gray"
        case .sleep: return "indigo"
        }
    }
}

// 重要度・緊急度マトリクス
enum PriorityMatrix: String, Codable, CaseIterable {
    case importantAndUrgent = "重要かつ緊急"
    case importantNotUrgent = "重要だが緊急でない"
    case notImportantAndUrgent = "重要でないが緊急"
    case notImportantNotUrgent = "重要でも緊急でもない"
    
    var quadrant: Int {
        switch self {
        case .importantAndUrgent: return 1
        case .importantNotUrgent: return 2
        case .notImportantAndUrgent: return 3
        case .notImportantNotUrgent: return 4
        }
    }
    
    var shortName: String {
        switch self {
        case .importantAndUrgent: return "重要・緊急"
        case .importantNotUrgent: return "重要・計画"
        case .notImportantAndUrgent: return "委任・緊急"
        case .notImportantNotUrgent: return "排除"
        }
    }
    
    var color: String {
        switch self {
        case .importantAndUrgent: return "red"
        case .importantNotUrgent: return "green"
        case .notImportantAndUrgent: return "yellow"
        case .notImportantNotUrgent: return "gray"
        }
    }
} 