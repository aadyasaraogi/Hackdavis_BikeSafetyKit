import Foundation
import CoreBluetooth

final class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    static let shared = BLEManager()

    private var central: CBCentralManager!

    private var peripheral: CBPeripheral?
    private var txCharacteristic: CBCharacteristic?

    private var messageQueue: [String] = []
    private var isReady = false
    private var isScanning = false

    // MARK: - YOUR ESP32 UUIDS
    private let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789abc")
    private let charUUID = CBUUID(string: "abcd1234-5678-90ab-cdef-123456789abc")

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - STATE CHANGE
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        switch central.state {

        case .poweredOn:
            print("🔵 BLE ON")

            startScanning()

        default:
            print("❌ BLE NOT READY:", central.state.rawValue)
            isReady = false
        }
    }

    // MARK: - SCANNING (IMPORTANT FIX)
    private func startScanning() {
        guard !isScanning else { return }

        print("🔍 Scanning for ESP32 service...")

        isScanning = true

        // 🔥 BEST PRACTICE: filter by SERVICE UUID
        central.scanForPeripherals(
            withServices: [serviceUUID],
            options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: false
            ]
        )
    }

    // MARK: - DISCOVERY
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {

        let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String
            ?? peripheral.name

        print("📡 Found:", name ?? "unknown", "| RSSI:", RSSI)

        // optional extra safety check
        guard peripheral.name?.contains("BIAS") == true ||
              (name?.contains("BIAS") == true) else {
            return
        }

        print("🎯 ESP32 MATCHED → connecting")

        self.peripheral = peripheral
        self.peripheral?.delegate = self

        isScanning = false
        central.stopScan()

        central.connect(peripheral, options: nil)
    }

    // MARK: - CONNECTED
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {

        print("✅ CONNECTED to ESP32")

        self.peripheral = peripheral
        isReady = false

        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }

    // MARK: - DISCONNECT RECOVERY
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {

        print("❌ DISCONNECTED → restarting scan")

        isReady = false
        txCharacteristic = nil
        self.peripheral = nil

        startScanning()
    }

    // MARK: - SERVICE DISCOVERY
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {

        guard let services = peripheral.services else { return }

        for service in services where service.uuid == serviceUUID {
            print("📦 Service found")

            peripheral.discoverCharacteristics([charUUID], for: service)
        }
    }

    // MARK: - CHARACTERISTIC DISCOVERY
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {

        guard let characteristics = service.characteristics else { return }

        for char in characteristics where char.uuid == charUUID {

            txCharacteristic = char
            isReady = true

            print("🟢 BLE READY")

            flushQueue()
            return
        }

        print("⚠️ Characteristic not found")
    }

    // MARK: - SEND DATA
    func send(_ value: String) {

        guard let peripheral = peripheral,
              let char = txCharacteristic,
              isReady else {

            print("⚠️ Queueing:", value)
            messageQueue.append(value)
            return
        }

        let data = Data(value.utf8)

        peripheral.writeValue(data, for: char, type: .withResponse)

        print("📤 Sent:", value)
    }

    // MARK: - QUEUE FLUSH
    private func flushQueue() {

        guard isReady else { return }

        while !messageQueue.isEmpty {
            let msg = messageQueue.removeFirst()
            send(msg)
        }
    }
}
