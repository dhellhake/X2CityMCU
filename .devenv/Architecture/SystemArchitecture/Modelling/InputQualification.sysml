package X2CityComponent_InputQualification {
    private import X2CitySharedContracts::*;
    private import X2CityContract_Input::*;
    part def InputQualification { // LE-INPUT-QUAL
        /* Retained qualification owner for non-accelerator observations, including the mechanical brake-lever state published through Input. Accelerator semantic qualification is owned by LE-ACCELERATOR-QUAL. */
        port brakeLeverStateOut:BrakeStateOutputPort { doc /* Publishes qualified mechanical lever state: true for either/both actuated, false only for qualified both-released. */ }
    }
}
