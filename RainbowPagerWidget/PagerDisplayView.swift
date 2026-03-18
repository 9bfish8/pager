import SwiftUI
import WidgetKit

struct PagerDisplayView: View {
    var isBlinkOn: Bool = true
    var displayMode: DisplayMode = .rainbow
    var ddayText: String = "D-365"
    var widgetTitle: String = "RAINBOW"
    var widgetIconName: String? = nil

    private var displayText: String {
        switch displayMode {
        case .rainbow: return widgetTitle
        case .dday: return ddayText
        }
    }

    private var displayFont: Font {
        let hasKorean = displayText.unicodeScalars.contains {
            (0xAC00...0xD7A3).contains($0.value) ||
            (0x3130...0x318F).contains($0.value)
        }
        return hasKorean
            ? .custom("Galmuri11", size: 24)
            : .custom("DS-Digital", size: 30)
    }

    private var lcdColors: [Color] {
        if isBlinkOn {
            return [
                Color(red: 0.45, green: 0.50, blue: 0.30),
                Color(red: 0.40, green: 0.45, blue: 0.25),
                Color(red: 0.35, green: 0.40, blue: 0.20)
            ]
        } else {
            return [
                Color(red: 0.30, green: 0.33, blue: 0.15),
                Color(red: 0.26, green: 0.29, blue: 0.12),
                Color(red: 0.22, green: 0.25, blue: 0.10)
            ]
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.38, green: 0.04, blue: 0.06),
                            Color(red: 0.30, green: 0.02, blue: 0.04),
                            Color(red: 0.22, green: 0.01, blue: 0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.clear,
                                    Color.clear,
                                    Color.white.opacity(0.03)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )

            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: lcdColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.black.opacity(0.4), lineWidth: 1)
                    )
                    .overlay(
                        VStack {
                            LinearGradient(
                                colors: [Color.black.opacity(0.2), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 8)
                            Spacer()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                    )

                Canvas { context, size in
                    for y in stride(from: 0, to: size.height, by: 2.5) {
                        let rect = CGRect(x: 0, y: y, width: size.width, height: 0.5)
                        context.fill(Path(rect), with: .color(.black.opacity(0.06)))
                    }
                    for x in stride(from: 0, to: size.width, by: 2.5) {
                        let rect = CGRect(x: x, y: 0, width: 0.3, height: size.height)
                        context.fill(Path(rect), with: .color(.black.opacity(0.03)))
                    }
                }

                // 아이콘 + 텍스트
                HStack(spacing: 4) {
                    if displayMode == .rainbow, let icon = widgetIconName {
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.12, green: 0.14, blue: 0.08))
                    }
                    Text(displayText)
                        .widgetAccentable()
                        .font(displayFont)
                        .bold()
                        .tracking(2)
                        .foregroundColor(Color(red: 0.12, green: 0.14, blue: 0.08))
                        .shadow(
                            color: Color(red: 0.12, green: 0.14, blue: 0.08).opacity(0.4),
                            radius: 0.5, x: 0.5, y: 0.5
                        )
                        .shadow(
                            color: Color(red: 0.12, green: 0.14, blue: 0.08).opacity(0.15),
                            radius: 1.5, x: 0, y: 0
                        )
                        .contentTransition(.identity)
                }

                RadialGradient(
                    colors: [
                        Color.white.opacity(isBlinkOn ? 0.08 : 0.02),
                        Color.clear
                    ],
                    center: .init(x: 0.3, y: 0.3),
                    startRadius: 0,
                    endRadius: 60
                )
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 6)
        }
    }
}

#Preview("RAINBOW 밝은 상태") {
    PagerDisplayView(isBlinkOn: true, displayMode: .rainbow, ddayText: "D-365", widgetTitle: "RAINBOW", widgetIconName: "heart.fill")
        .frame(width: 170, height: 70)
}

#Preview("DDAY 밝은 상태") {
    PagerDisplayView(isBlinkOn: true, displayMode: .dday, ddayText: "D-365", widgetTitle: "RAINBOW", widgetIconName: nil)
        .frame(width: 170, height: 70)
}
