//
//  MatrixChartView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//

import SwiftUI

struct MatrixChartView: View {
    let activities: [ActivityLog]
    
    private var matrixData: [MatrixData] {
        let grouped = Dictionary(grouping: activities) { $0.priority }
        let totalMinutes = activities.reduce(0) { $0 + $1.durationInMinutes }
        
        return PriorityMatrix.allCases.map { priority in
            let priorityActivities = grouped[priority] ?? []
            let minutes = priorityActivities.reduce(0) { $0 + $1.durationInMinutes }
            let percentage = totalMinutes > 0 ? Double(minutes) / Double(totalMinutes) * 100 : 0
            
            return MatrixData(
                priority: priority,
                minutes: minutes,
                percentage: percentage,
                color: Color(priority.color)
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Enhanced Matrix Display
            VStack(spacing: 0) {
                // Axis Labels (Top)
                HStack {
                    Spacer()
                        .frame(width: 40)
                    
                    Text("緊急度")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                HStack(spacing: 0) {
                    // Y-Axis Label
                    VStack {
                        Text("重")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Text("要")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Text("度")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    .frame(width: 40)
                    
                    // Matrix Grid
                    VStack(spacing: 4) {
                        // Top Row Labels
                        HStack(spacing: 4) {
                            Text("低")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                            
                            Text("高")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 4)
                        
                        // Matrix Quadrants
                        VStack(spacing: 4) {
                            // Top Row (Important)
                            HStack(spacing: 4) {
                                EnhancedQuadrantView(
                                    data: matrixData.first { $0.priority == .importantNotUrgent }!,
                                    quadrant: 2,
                                    title: "計画・準備",
                                    description: "最も重要な領域",
                                    isOptimal: true
                                )
                                
                                EnhancedQuadrantView(
                                    data: matrixData.first { $0.priority == .importantAndUrgent }!,
                                    quadrant: 1,
                                    title: "緊急対応",
                                    description: "すぐに対処が必要",
                                    isOptimal: false
                                )
                            }
                            
                            // Bottom Row (Not Important)
                            HStack(spacing: 4) {
                                EnhancedQuadrantView(
                                    data: matrixData.first { $0.priority == .notImportantNotUrgent }!,
                                    quadrant: 4,
                                    title: "無用な活動",
                                    description: "できる限り排除",
                                    isOptimal: false
                                )
                                
                                EnhancedQuadrantView(
                                    data: matrixData.first { $0.priority == .notImportantAndUrgent }!,
                                    quadrant: 3,
                                    title: "誤った緊急",
                                    description: "委任を検討",
                                    isOptimal: false
                                )
                            }
                        }
                        
                        // Side Labels
                        HStack {
                            Text("高")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Text("低")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 4)
                        .rotationEffect(.degrees(90))
                        .frame(height: 20)
                    }
                }
            }
            .padding(16)
            .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            
            // Matrix Insights
            MatrixInsightsView(matrixData: matrixData)
        }
    }
}

struct MatrixData {
    let priority: PriorityMatrix
    let minutes: Int
    let percentage: Double
    let color: Color
}

struct EnhancedQuadrantView: View {
    let data: MatrixData
    let quadrant: Int
    let title: String
    let description: String
    let isOptimal: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Quadrant Number Badge
            HStack {
                Text("\(quadrant)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(.white.opacity(0.3)))
                
                Spacer()
                
                if isOptimal {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                }
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("\(data.minutes)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                + Text("分")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.9))
                
                Text("\(String(format: "%.1f", data.percentage))%")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.white.opacity(0.2), in: Capsule())
            }
        }
        .frame(maxWidth: .infinity, minHeight: 110)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [data.color, data.color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: data.color.opacity(0.3), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isOptimal ? .yellow.opacity(0.6) : .clear, lineWidth: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("第\(quadrant)象限: \(title), \(data.minutes)分, \(String(format: "%.1f", data.percentage))パーセント")
    }
}

struct MatrixInsightsView: View {
    let matrixData: [MatrixData]
    
    private var totalMinutes: Int {
        matrixData.reduce(0) { $0 + $1.minutes }
    }
    
    private var optimalTimePercentage: Double {
        let optimalMinutes = matrixData.first(where: { $0.priority == .importantNotUrgent })?.minutes ?? 0
        return totalMinutes > 0 ? Double(optimalMinutes) / Double(totalMinutes) * 100 : 0
    }
    
    private var insight: (message: String, recommendation: String, color: Color) {
        switch optimalTimePercentage {
        case 40...:
            return ("素晴らしい時間配分です！", "第2象限の活動を継続し、さらに効率化を図りましょう", .green)
        case 20..<40:
            return ("良い時間管理ができています", "第2象限の活動をもう少し増やすことを検討してください", .blue)
        case 10..<20:
            return ("改善の余地があります", "計画的な活動（第2象限）に more時間を割くことを推奨します", .orange)
        default:
            return ("時間管理を見直しましょう", "重要で緊急でない活動（第2象限）を増やすことが重要です", .red)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.headline)
                    .foregroundStyle(insight.color)
                
                Text("時間管理の洞察")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(insight.message)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(insight.color)
                
                Text(insight.recommendation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Text("第2象限の時間割合:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(String(format: "%.1f", optimalTimePercentage))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(insight.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(insight.color.opacity(0.1), in: Capsule())
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let sampleActivities = [
        ActivityLog(
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            memo: "緊急会議",
            category: .work,
            priority: .importantAndUrgent
        ),
        ActivityLog(
            startTime: Date().addingTimeInterval(3600),
            endTime: Date().addingTimeInterval(7200),
            memo: "スキルアップ学習",
            category: .learning,
            priority: .importantNotUrgent
        ),
        ActivityLog(
            startTime: Date().addingTimeInterval(7200),
            endTime: Date().addingTimeInterval(9000),
            memo: "急な電話対応",
            category: .work,
            priority: .notImportantAndUrgent
        ),
        ActivityLog(
            startTime: Date().addingTimeInterval(9000),
            endTime: Date().addingTimeInterval(10800),
            memo: "SNSチェック",
            category: .hobby,
            priority: .notImportantNotUrgent
        )
    ]
    
    MatrixChartView(activities: sampleActivities)
        .padding()
} 