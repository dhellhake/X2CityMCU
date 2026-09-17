package X2CityDetailedSharedContracts {
    // Detailed-design-only common qualifiers. Boundary information identities remain owned by SoftwareArchitecture.
    private import X2CitySharedSoftwareTypes::*;
    attribute def UnitProducer;
    attribute def UnitReceiptOrder;
    attribute def UnitValue;
    attribute def UnitQualification :> Qualification;
    item def UnitInformationEnvelope :> ContextualSoftwareInformation {
        attribute producer:UnitProducer;
        attribute receiptOrder:UnitReceiptOrder;
        attribute value:UnitValue;
        attribute qualification:UnitQualification :>> ContextualSoftwareInformation::qualification;
    }
    // UnitInformationEnvelope is retained for pre-existing local generic records. Vehicle sensor,
    // calibration and health routes use their imported SoftwareArchitecture records directly;
    // their common compatible supertype at collection/eligibility boundaries is
    // ContextualSoftwareInformation, not this DD-only extension.
}
