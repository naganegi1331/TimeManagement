//
//  PieChartComponents.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//  Refactored: Separated from CategoryPieChartView.swift for better organization
//

import SwiftUI

// MARK: - Pie Chart Components

struct EnhancedPieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    let isHighlighted: Bool
    
    var body: some View {
        Path { path in
            let center = CGPoint(x: 85, y: 85)
            let outerRadius: CGFloat = isHighlighted ? 82 : 80
            let innerRadius: CGFloat = 45
            
            // Outer arc
            path.addArc(
                center: center,
                radius: outerRadius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
            
            // Inner arc (reverse)
            path.addArc(
                center: center,
                radius: innerRadius,
                startAngle: endAngle,
                endAngle: startAngle,
                clockwise: true
            )
            
            path.closeSubpath()
        }
        .fill(
            LinearGradient(
                colors: [color, color.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            Path { path in
                let center = CGPoint(x: 85, y: 85)
                let outerRadius: CGFloat = isHighlighted ? 82 : 80
                let innerRadius: CGFloat = 45
                
                path.addArc(
                    center: center,
                    radius: outerRadius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
                
                path.addArc(
                    center: center,
                    radius: innerRadius,
                    startAngle: endAngle,
                    endAngle: startAngle,
                    clockwise: true
                )
                
                path.closeSubpath()
            }
            .stroke(.white, lineWidth: 1.5)
        )
        .scaleEffect(isHighlighted ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHighlighted)
    }
} 