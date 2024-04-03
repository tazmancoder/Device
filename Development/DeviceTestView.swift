import SwiftUI
#if canImport(Device) // since this is needed in XCode but is unavailable in Playgrounds.
import Device
#endif

extension Device.Idiom {
    var color: Color {
        switch self {
        case .unspecified:
                .gray
        case .mac:
                .blue
        case .pod:
                .mint
        case .phone:
                .red
        case .pad:
                .purple
        case .tv:
                .brown
        case .homePod:
                .pink
        case .watch:
                .red
        case .carPlay:
                .green
        case .vision:
                .yellow
        }
    }
}

struct TimeClockView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var time = Date()
    
    var battery: some View {
        Group {
            if let battery = Device.current.battery {
                BatteryView(battery: battery, fontSize: 80)
            } else {
                Image(symbolName: "batteryblock.slash") // battery.slash
                    .font(.system(size: 80))
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("Current time: \(time.formatted(date: .long, time: .complete))")
            if let battery = Device.current.battery {
                Text("Battery Info: \(battery.description)")
            } else {
                Text("No Battery")
            }
            HStack {
                NavigationLink {
                    BatteryListView()
                } label: {
                    battery
                }
            }
        }
        .onReceive(timer, perform: { _ in
            //debug("updating \(time)")
            time = Date()
        })
    }
}

struct StackedLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon.font(.title2)
            configuration.title.font(.caption2)
        }
    }
}

struct Placard: View {
    @State var color = Color.gray
    var body: some View {
        return RoundedRectangle(cornerRadius: 10)
            .strokeBorder(.primary, lineWidth: 3)
            .background(RoundedRectangle(cornerRadius: 10).fill(color))
    }
}

struct TestCard: View {
    @State var label = "Unknown"
    @State var highlighted = true
    @State var color = Color.gray
    @State var symbolName = String.symbolUnknownEnvironment
    var body: some View {
        Placard(color: highlighted ? color : .clear)
            .overlay {
                Label(label, symbolName: symbolName)
                    .font(.caption)
                    .symbolRenderingMode(highlighted ? .hierarchical : .monochrome)
            }
    }
}

struct HardwareListView: View {
    @State private var selection: Device.Idiom?
    var body: some View {
        List {
            Section("Idioms") {
                ForEach(Device.Idiom.allCases) { idiom in
                    let label = Label(idiom.description, symbolName: idiom.symbolName)
                        .foregroundColor(.primary)
                        .font(.headline)
                    if Device.current.idiom == idiom {
                        label
                            .listRowBackground(idiom.color)
                    } else {
                        label
                    }
                }
            }
            Section("Capabilities") {
                ForEach(Capability.allCases, id: \.self) { capability in
                    let label = HStack {
                        Label(String(describing: capability), symbolName: capability.symbolName)
                        //                        .accessibilityLabel(capability.description)
                    }
                    if Device.current.has(capability) {
                        label
                            .listRowBackground(Color.green)
                    } else {
                        label
                    }
                }
            }
        }
        .navigationTitle("Hardware")
    }
}

#Preview("HardwareList") {
    NavigationView {
        HardwareListView()
    }
}


public struct BatteryListView: View {
    public var fontSize: CGFloat = 40
    @State private var selection: Device.Idiom?
    public var body: some View {
        List {
            ForEach(MockBattery.mocks) { mock in
                HStack {
                    BatteryView(battery: mock, useSystemColors: true, includePercent: true, fontSize: fontSize)
                    BatteryView(battery: mock, useSystemColors: true, includePercent: false, fontSize: fontSize)
                    Spacer()
                    BatteryView(battery: mock, useSystemColors: false, includePercent: false, fontSize: fontSize)
                    BatteryView(battery: mock, useSystemColors: false, includePercent: true, fontSize: fontSize)
                }
            }
        }
        .navigationTitle("Battery Mocks")
    }
}

#Preview("BatteryList") {
    NavigationView {
        BatteryListView()
    }
}


public struct DeviceTestView: View {
    @State var showList = false
    public var version: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Unknown"
    }
    public var idiomList: some View {
        ForEach(Device.Idiom.allCases) { idiom in
            TestCard(
                label: idiom.description,
                highlighted: Device.current.idiom == idiom,
                color: Device.current.idiom.color,
                symbolName: idiom.symbolName)
        }
    }
    
    var testView: some View {
        List {
            Section {
                TimeClockView()
            } header: {
                HStack {
                    Text("Device v\(version)")
                    Spacer()
                    Text(verbatim: "© \(Calendar.current.component(.year, from: Date())) Kudit, LLC")
                }
            }.buttonStyle(.plain)
            NavigationLink(destination: {
                HardwareListView()
            }, label: {
                VStack(alignment: .leading) {
                    HStack {
                        Image(symbolName: Device.current.symbolName)
                            .font(.system(size: 80))
                        VStack(alignment: .leading) {
                            Text("Current device:")
                                .font(.headline)
                            Text("\(Device.current.identifier)")
                                .italic()
                            Text("\(Device.current.name ?? "nil")")
                            Text("Running **\(Device.current.systemName ?? "nil")**")
                        }
                    }
                    HStack {
                        //                    TestCard(label: "TEST", highlighted: true, color: .yellow, symbolName: "star.fill")
                        TestCard(
                            label: "Preview",
                            highlighted: Device.current.isPreview,
                            color: .orange,
                            symbolName: .symbolPreview
                        )
                        TestCard(
                            label: "Playground",
                            highlighted: Device.current.isPlayground,
                            color: .pink,
                            symbolName: .symbolPlayground)
                        TestCard(
                            label: "Simulator",
                            highlighted: Device.current.isSimulator,
                            color: .blue,
                            symbolName: .symbolSimulator)
                        TestCard(
                            label: "Real Device",
                            highlighted: Device.current.isRealDevice,
                            color: .green,
                            symbolName: .symbolRealDevice)
                        if [.mac, .vision].contains(Device.current.idiom) {
                            TestCard(
                                label: "Designed for iPad",
                                highlighted: Device.current.isDesignedForiPad,
                                color: .purple,
                                symbolName: .symbolDesignedForiPad)
                        }
                    }
                    .labelStyle(StackedLabelStyle())
                    .frame(height: 60)
                }
            })
            NavigationLink(destination: {
                DeviceListView(devices: Device.all)
                    .toolbar {
                        Button("Migrate") {
                            migrateContent()
                        }
                    }
            }, label: {
                DeviceInfoView(device: Device.current)
            })
        }
        .navigationTitle("Device.swift")
    }
    
    public var body: some View {
        NavigationView {
            testView
        }
    }
    
    /// For testing and migrating code during development.
    func migrateContent() {
        Migration.migrate()
    }
}

#Preview("DeviceTestView") {
    DeviceTestView()
}



