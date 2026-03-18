import Foundation

struct DDay: Codable, Identifiable {
    let id: UUID
    var title: String
    var iconName: String?
    var targetDate: Date
    var isSelected: Bool
    
    init(id: UUID = UUID(), title: String = "RAINBOW", iconName: String? = nil, targetDate: Date, isSelected: Bool = false) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.targetDate = targetDate
        self.isSelected = isSelected
    }

    enum CodingKeys: String, CodingKey {
        case id, title, iconName, targetDate, isSelected
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "RAINBOW"
        iconName = try container.decodeIfPresent(String.self, forKey: .iconName)
        targetDate = try container.decode(Date.self, forKey: .targetDate)
        isSelected = try container.decode(Bool.self, forKey: .isSelected)
    }
    
    var ddayText: String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
        return days >= 0 ? "D-\(days)" : "D+\(abs(days))"
    }
}
