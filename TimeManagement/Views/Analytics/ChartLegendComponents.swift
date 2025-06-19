//
//  ChartLegendComponents.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//  Refactored: Separated from CategoryPieChartView.swift for better organization
//

import SwiftUI

// MARK: - Chart Legend Components

// 象限別Legend セクション
struct QuadrantLegendSection: View {
    let quadrant: Int
    let data: [QuadrantChartData]
    
    private var quadrantTitle: String {
        switch quadrant {
        case 1: return "第1象限（重要・緊急）"
        case 2: return "第2象限（重要・非緊急）"
        case 3: return "第3象限（非重要・緊急）"
        case 4: return "第4象限（非重要・非緊急）"
        default: return "その他"
        }
    }
    
    private var quadrantColor: Color {
        switch quadrant {
        case 1: return .red
        case 2: return .blue
        case 3: return .orange
        case 4: return .gray
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Quadrant Header
            HStack(spacing: 8) {
                Circle()
                    .fill(quadrantColor)
                    .frame(width: 12, height: 12)
                
                Text(quadrantTitle)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                let totalMinutes = data.reduce(0) { $0 + $1.minutes }
                Text("\(totalMinutes)分")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            // Category items in this quadrant
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(data, id: \.category) { item in
                    QuadrantLegendItem(data: item)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(quadrantColor.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(quadrantColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// 象限別Legend アイテム
struct QuadrantLegendItem: View {
    let data: QuadrantChartData
    
    var body: some View {
        HStack(spacing: 6) {
            // Category icon
            ZStack {
                Circle()
                    .fill(data.color.opacity(0.15))
                    .frame(width: 20, height: 20)
                
                Image(systemName: data.category.icon)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(data.color)
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text(data.category.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 2) {
                    Text("\(data.minutes)分")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text("(\(String(format: "%.1f", data.percentage * 100))%)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Material.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 6))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(data.category.rawValue): \(data.minutes)分, \(String(format: "%.1f", data.percentage * 100))パーセント")
    }
}

struct LegendItem: View {
    let data: ChartData
    
    var body: some View {
        HStack(spacing: 8) {
            // Icon with category symbol
            ZStack {
                Circle()
                    .fill(data.color.opacity(0.2))
                    .frame(width: 28, height: 28)
                
                Image(systemName: data.category.icon)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(data.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(data.category.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text("\(data.minutes)分")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    Text("(\(String(format: "%.1f", data.percentage * 100))%)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(.quaternary, in: Capsule())
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(data.category.rawValue): \(data.minutes)分, \(String(format: "%.1f", data.percentage * 100))パーセント")
    }
} 