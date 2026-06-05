import Foundation

enum DocumentType: String, Codable {
    case deathCertificate      = "death_certificate"
    case incidentReport        = "incident_report"
    case citizenRecord         = "citizen_record"
    case finalMessage          = "final_message"
    case corporateNotice       = "corporate_notice"
    case housingRelocation     = "housing_relocation"
    case restrictedPhraseList  = "restricted_phrase_list"
    case hospitalRecord        = "hospital_record"
    case identityRecord        = "identity_record"
    case anomalyWarning        = "anomaly_warning"
    case auditLog              = "audit_log"
    case dataCartridge         = "data_cartridge"
}

struct DocumentField: Codable {
    var key: String
    var value: String
    var isSuspicious: Bool
    var suspicionNote: String?
}

struct Stamp: Codable {
    var text: String
    var color: String     // Hex
    var appliedDate: String?
    var appliedBy: String?
}

struct DocumentModel: Codable, Identifiable {
    var id: String
    var title: String
    var type: DocumentType
    var issuer: String
    var issueDate: String
    var referenceNumber: String
    var fields: [DocumentField]
    var bodyText: String
    var footerText: String?
    var stamps: [Stamp]
    var classificationLevel: String   // "STANDARD", "RESTRICTED", "CLASSIFIED"
    var isTampered: Bool
}
