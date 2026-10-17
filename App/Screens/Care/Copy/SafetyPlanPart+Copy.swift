/**
 The words of each part of Rencana Keselamatanku, as the boards write them: its title (also the
 form's field label), the pencil's name, and the form's hint.
 */
import Features
import Foundation

extension SafetyPlanPart {
    /** "Tanda Aku Mulai Berat" … "Tempat Aku Merasa Aman". */
    var title: LocalizedStringResource {
        switch self {
        case .warningSigns: "care.plan.warningSigns"
        case .calmingThings: "care.plan.calmingThings"
        case .people: "care.plan.people"
        case .professionals: "care.plan.professionals"
        case .safePlace: "care.plan.safePlace"
        }
    }

    /** The pencil's name: "Ubah Tanda Aku Mulai Berat". */
    var editLabel: LocalizedStringResource {
        switch self {
        case .warningSigns: "care.plan.warningSigns.edit"
        case .calmingThings: "care.plan.calmingThings.edit"
        case .people: "care.plan.people.edit"
        case .professionals: "care.plan.professionals.edit"
        case .safePlace: "care.plan.safePlace.edit"
        }
    }

    /** The form's hint under the field: "Contoh: susah tidur, malas buka chat". */
    var hint: LocalizedStringResource {
        switch self {
        case .warningSigns: "care.plan.warningSigns.hint"
        case .calmingThings: "care.plan.calmingThings.hint"
        case .people: "care.plan.people.hint"
        case .professionals: "care.plan.professionals.hint"
        case .safePlace: "care.plan.safePlace.hint"
        }
    }
}
