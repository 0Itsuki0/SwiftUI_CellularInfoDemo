
import CoreTelephony
import SwiftUI

extension String {
    var ratDescription: String? {
        switch self {

        // MARK: - 2G
        case CTRadioAccessTechnologyGPRS:
            return "2G (GPRS)"
        case CTRadioAccessTechnologyEdge:
            return "2G (EDGE)"

        // MARK: - 3G (GSM / UMTS)
        case CTRadioAccessTechnologyWCDMA:
            return "3G (WCDMA)"
        case CTRadioAccessTechnologyHSDPA:
            return "3G (HSDPA)"
        case CTRadioAccessTechnologyHSUPA:
            return "3G (HSUPA)"

        // MARK: - 3G (CDMA)
        case CTRadioAccessTechnologyCDMA1x:
            return "2G (CDMA 1x)"
        case CTRadioAccessTechnologyCDMAEVDORev0:
            return "3G (EV-DO Rev.0)"
        case CTRadioAccessTechnologyCDMAEVDORevA:
            return "3G (EV-DO Rev.A)"
        case CTRadioAccessTechnologyCDMAEVDORevB:
            return "3G (EV-DO Rev.B)"
        case CTRadioAccessTechnologyeHRPD:
            return "3G (eHRPD)"

        // MARK: - 4G
        case CTRadioAccessTechnologyLTE:
            return "4G (LTE)"

        // MARK: - 5G
        case CTRadioAccessTechnologyNRNSA:
            return "5G (NSA)"
        case CTRadioAccessTechnologyNR:
            return "5G (NR)"

        default:
            return nil
        }
    }
}

extension CTCellularDataRestrictedState {
    var description: String {
        switch self {
        case .restrictedStateUnknown:
            return
                "The system has not yet determined the cellular data access status."
        case .restricted:
            return "Cellular data usage is blocked for the app."
        case .notRestricted:
            return "Cellular data usage is allowed."
        @unknown default:
            return
                "The system has not yet determined the cellular data access status."
        }
    }
}

@Observable
class CellularInfoManager: NSObject, CTTelephonyNetworkInfoDelegate {
    var radioAccessTechnology: String? {
        guard let dataServiceIdentifier else {
            return nil
        }
        return self.networkInfo.serviceCurrentRadioAccessTechnology?[
            dataServiceIdentifier
        ]
    }

    private(set) var cellularDataRestricted: CTCellularDataRestrictedState

    private let cellularData = CTCellularData()
    private let networkInfo = CTTelephonyNetworkInfo()
    private var dataServiceIdentifier: String?

    override init() {
        self.dataServiceIdentifier = networkInfo.dataServiceIdentifier
        self.cellularDataRestricted = cellularData.restrictedState
        super.init()
        // for monitoring cellular service change
        self.networkInfo.delegate = self
        // for monitoring cellular data restriction change
        self.cellularData.cellularDataRestrictionDidUpdateNotifier = { state in
            self.cellularDataRestricted = state
        }
    }

    // MARK: CTTelephonyNetworkInfoDelegate Implementation
    func dataServiceIdentifierDidChange(_ identifier: String) {
        self.dataServiceIdentifier = identifier
    }
}


struct CellularInfoDemo: View {
    @State private var manager = CellularInfoManager()
    var body: some View {

        NavigationStack {
            List {
                if let radioAccessTechnology = self.manager
                    .radioAccessTechnology
                {
                    Section("Cellular Network Type") {
                        VStack(
                            alignment: .leading,
                            spacing: 8,
                            content: {
                                Text(
                                    radioAccessTechnology.ratDescription
                                        ?? radioAccessTechnology
                                )
                                .fontWeight(.medium)
                            }
                        )
                    }
                }

                Section("Cellular Data Access") {
                    VStack(
                        alignment: .leading,
                        spacing: 8,
                        content: {
                            Text(
                                self.manager.cellularDataRestricted.description
                            )
                            .fontWeight(.medium)
                        }
                    )
                }
            }
            .navigationTitle("Cellular Info")
        }
    }
}
