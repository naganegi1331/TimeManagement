//
//  ChartDataModels.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//  Refactored: Separated from CategoryPieChartView.swift for better organization
//

import SwiftUI

// MARK: - Chart Data Models

// 象限別チャートデータ
struct QuadrantChartData {
    let category: ActivityCategory
    let quadrant: Int
    let minutes: Int
    let percentage: Double
    let color: Color
    let priority: PriorityMatrix
}

// 後方互換性のためのChartData（必要に応じて削除可能）
struct ChartData {
    let category: ActivityCategory
    let minutes: Int
    let percentage: Double
    let color: Color
} 