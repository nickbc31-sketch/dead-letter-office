import Foundation

/// Maps PDA journal tags to memorable people, places, and case references.
enum InvestigationLinkResolver {

    static func people(for tags: [String]) -> [String] {
        var names = Set<String>()
        for tag in tags {
            switch tag {
            case "case_4471", "marr_unit_312":
                names.formUnion(["Lina Marr", "Olen Marr"])
            case "elias_venn":
                names.insert("Elias Venn")
            case "quiet_choir":
                names.insert("Quiet Choir contacts")
            case "helix_routing":
                names.insert("Jun Vale")
            case "block_p03":
                names.insert("Orvin Hale")
            case "saint_orra":
                names.insert("Saint Orra")
            case "pmca_record_alteration":
                names.insert("Director Calyx")
            default:
                break
            }
        }
        if tags.contains(where: { $0.hasPrefix("ch") }) {
            names.insert("K. Haas")
        }
        return names.sorted()
    }

    static func locations(for tags: [String]) -> [String] {
        var places = Set<String>()
        for tag in tags {
            switch tag {
            case "relay_building":
                places.insert("Relay Building")
            case "transit_line_9", "helix_routing":
                places.insert("Transit Line 9")
            case "block_p03", "marr_unit_312":
                places.insert("Block P03 — Unit 312")
            case "citizen_erasure":
                places.insert("East Transit Node")
            default:
                break
            }
        }
        return places.sorted()
    }

    static func linkedCases(for tags: [String]) -> [String] {
        var cases = Set<String>()
        for tag in tags {
            switch tag {
            case "case_4471":
                cases.insert("C01 — Marr")
            case "marr_unit_312":
                cases.insert("C09 — Lina appeal")
            case "elias_venn":
                cases.insert("C04 — Venn routing")
            case "helix_routing":
                cases.insert("C05 — Helix trial")
            default:
                break
            }
        }
        return cases.sorted()
    }
}
