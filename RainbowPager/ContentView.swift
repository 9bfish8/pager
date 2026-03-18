import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var ddays: [DDay] = []
    @State private var showDatePicker = false
    @State private var newDate: Date = Date()
    @State private var newTitle: String = ""
    @State private var newIconName: String? = nil
    @State private var editingDDay: DDay? = nil
    
    private let appGroup = "group.com.reum.rainbowpager"
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.08)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("📟 RAINBOW PAGER")
                        .font(.system(.headline, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.30))
                    Spacer()
                    Button {
                        newTitle = ""
                        newIconName = nil
                        newDate = Date()
                        editingDDay = nil
                        showDatePicker = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.30))
                            .font(.title2)
                    }
                }
                .padding(24)
                
                if ddays.isEmpty {
                    Spacer()
                    Text("+ 버튼으로 디데이를 추가해줘")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        ForEach(ddays) { dday in
                            HStack {
                                Button {
                                    selectForWidget(dday)
                                } label: {
                                    Image(systemName: dday.isSelected ? "circle.fill" : "circle")
                                        .foregroundColor(dday.isSelected ? Color(red: 0.45, green: 0.50, blue: 0.30) : .gray)
                                }
                                .buttonStyle(.plain)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        if let icon = dday.iconName {
                                            Image(systemName: icon)
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.30))
                                        }
                                        Text(dday.title)
                                            .font(.system(.body, design: .monospaced))
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.30))
                                    }
                                    Text(dday.ddayText)
                                        .font(.system(.title2, design: .monospaced))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text(dday.targetDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                if dday.isSelected {
                                    Text("위젯")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color(red: 0.45, green: 0.50, blue: 0.30))
                                        )
                                }
                                
                                Button {
                                    editingDDay = dday
                                    newTitle = dday.title
                                    newIconName = dday.iconName
                                    newDate = dday.targetDate
                                    showDatePicker = true
                                } label: {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                }
                                .buttonStyle(.plain)
                                .padding(.leading, 8)
                            }
                            .listRowBackground(Color(red: 0.15, green: 0.15, blue: 0.15))
                        }
                        .onDelete(perform: deleteDDay)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(
                newDate: $newDate,
                newTitle: $newTitle,
                newIconName: $newIconName,
                isEditing: editingDDay != nil
            ) {
                if editingDDay != nil {
                    updateDDay()
                } else {
                    addDDay()
                }
                showDatePicker = false
            }
            .presentationDetents([.medium, .large])  // ← 추가

        }
        .onAppear {
            loadDDays()
        }
    }
    
    private func selectForWidget(_ dday: DDay) {
        for i in ddays.indices {
            ddays[i].isSelected = ddays[i].id == dday.id
        }
        saveDDays()
        
        let defaults = UserDefaults(suiteName: appGroup)
        defaults?.set(dday.targetDate, forKey: "ddayTargetDate")
        defaults?.set(dday.title, forKey: "ddayTitle")
        defaults?.set(dday.iconName, forKey: "ddayIconName")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func addDDay() {
        let title = newTitle.trimmingCharacters(in: .whitespaces).isEmpty ? "RAINBOW" : newTitle.uppercased()
        let newDDay = DDay(title: title, iconName: newIconName, targetDate: newDate)
        ddays.append(newDDay)
        saveDDays()
    }
    
    private func updateDDay() {
        guard let editing = editingDDay,
              let index = ddays.firstIndex(where: { $0.id == editing.id }) else { return }
        let title = newTitle.trimmingCharacters(in: .whitespaces).isEmpty ? "RAINBOW" : newTitle.uppercased()
        ddays[index].title = title
        ddays[index].iconName = newIconName
        ddays[index].targetDate = newDate
        saveDDays()
        
        if ddays[index].isSelected {
            let defaults = UserDefaults(suiteName: appGroup)
            defaults?.set(newDate, forKey: "ddayTargetDate")
            defaults?.set(title, forKey: "ddayTitle")
            defaults?.set(newIconName, forKey: "ddayIconName")
            WidgetCenter.shared.reloadAllTimelines()
        }
        editingDDay = nil
    }
    
    private func deleteDDay(at offsets: IndexSet) {
        ddays.remove(atOffsets: offsets)
        saveDDays()
        
        if !ddays.contains(where: { $0.isSelected }) {
            let defaults = UserDefaults(suiteName: appGroup)
            defaults?.removeObject(forKey: "ddayTargetDate")
            defaults?.removeObject(forKey: "ddayTitle")
            defaults?.removeObject(forKey: "ddayIconName")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private func saveDDays() {
        if let encoded = try? JSONEncoder().encode(ddays) {
            UserDefaults.standard.set(encoded, forKey: "ddays")
        }
    }
    
    private func loadDDays() {
        if let data = UserDefaults.standard.data(forKey: "ddays"),
           let decoded = try? JSONDecoder().decode([DDay].self, from: data) {
            ddays = decoded
        }
    }
}

// MARK: - DatePicker Sheet

struct DatePickerSheet: View {
    @Binding var newDate: Date
    @Binding var newTitle: String
    @Binding var newIconName: String?
    var isEditing: Bool = false
    var onSave: () -> Void
    
    let icons = ["heart.fill", "star.fill", "birthday.cake.fill", "bell.fill"]
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.08)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text(isEditing ? "디데이 수정" : "디데이 추가")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.30))
                
                // 텍스트 + 아이콘 선택
                VStack(alignment: .leading, spacing: 8) {
                    Text("위젯에 표시할 텍스트")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        // 아이콘 선택 버튼
                        Menu {
                            Button {
                                newIconName = nil
                            } label: {
                                Label("없음", systemImage: "xmark")
                            }
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    newIconName = icon
                                } label: {
                                    Label(icon, systemImage: icon)
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                                    .frame(width: 44, height: 44)
                                if let icon = newIconName {
                                    Image(systemName: icon)
                                        .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.30))
                                        .font(.system(size: 18))
                                } else {
                                    Image(systemName: "face.smiling")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 18))
                                }
                            }
                        }
                        
                        TextField("RAINBOW", text: $newTitle)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                            )
                            .autocorrectionDisabled()
                    }
                }
                .padding(.horizontal, 24)
                
                DatePicker(
                    "",
                    selection: $newDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .colorScheme(.dark)
                .labelsHidden()
                
                Button {
                    onSave()
                } label: {
                    Text(isEditing ? "수정" : "추가")
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 0.45, green: 0.50, blue: 0.30))
                        )
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 24)
        }
    }
}

#Preview {
    ContentView()
}
