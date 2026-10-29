package X2CityContract_LightControl {
    private import X2CitySharedContracts::*;

    item def NormalLightRequest:>QualifiedInformationRecord {
        doc /* HMI's accepted normal-light On/Off request. Its qualification distinguishes a current accepted request from unavailable input; retaining a prior valid request is a LightModeSelection responsibility. */
        attribute normalLightRequestedOn:Boolean;
    }

    item def LightingAvailability {
        doc /* Qualified budget-derived operational lighting availability constraint from CurrentConsumptionCoordination; it is not measured supply or lamp output.
         * Available false inhibits all illumination, including rear Full and startup fallback. True permits current selected modes subject to EnergyPath physical supply and protection; it neither proves supply or lamp output nor commands On.
         * Unqualified information is not known false. In the live powered actuation context, loss, invalidity, or expiry cannot release a known qualified false restriction; only a new qualified true can release it. Qualification includes transport expiry or timeout evaluated using trusted time, without additional public freshness fields. */
        attribute Available:Boolean;
        item Qualification:QualifiedInformationRecord;
    }

    enum def FrontLightMode { enum Off; enum On; }
    enum def RearLightMode { enum Off; enum Dim; enum Full; }

    item def LightModes {
        doc /* Composite provided from selection to actuation: Front is an Off/On enum, Rear is an Off/Dim/Full enum, and modesAvailable states whether a usable software mode selection exists. */
        attribute Front:FrontLightMode;
        attribute Rear:RearLightMode;
        attribute modesAvailable:Boolean { doc /* false selects the powered initial, start, or reset fallback: Front Off and Rear Full, subject to any current or retained qualified unavailable restriction and to supply and protection. */ }
    }

    item def FrontIllumination {
        doc /* Physical front Off/On illumination result provided by LightActuation. This is the intended physical result, not lamp telemetry or a measured status. */
        attribute Front:FrontLightMode;
    }

    item def RearIllumination {
        doc /* Physical rear Off/Dim/Full illumination result provided by LightActuation. This is the intended physical result, not lamp telemetry or a measured status. */
        attribute Rear:RearLightMode;
    }

    port def NormalLightRequestOutputPort {
        doc /* Publishes HMI's accepted normal-light On/Off request with qualification. */
        out item normalLightRequest:NormalLightRequest;
    }
    port def NormalLightRequestInputPort {
        doc /* Receives HMI's accepted normal-light On/Off request with qualification. */
        in item normalLightRequest:NormalLightRequest;
    }
    port def LightingAvailabilityOutputPort {
        doc /* Publishes the qualified budget-derived operational lighting availability constraint. */
        out item lightingAvailability:LightingAvailability;
    }
    port def LightingAvailabilityInputPort {
        doc /* Receives the qualified budget-derived operational lighting availability constraint. */
        in item lightingAvailability:LightingAvailability;
    }
    port def LightModesOutputPort {
        doc /* Publishes selected Front/Rear logical modes and their availability for physical actuation. */
        out item lightModes:LightModes;
    }
    port def LightModesInputPort {
        doc /* Receives selected Front/Rear logical modes and their availability for physical actuation. */
        in item lightModes:LightModes;
    }
    port def FrontIlluminationOutputPort {
        doc /* Provides the physical front illumination result; it is not a feedback or status channel. */
        out item frontIllumination:FrontIllumination;
    }
    port def RearIlluminationOutputPort {
        doc /* Provides the physical rear illumination result; it is not a feedback or status channel. */
        out item rearIllumination:RearIllumination;
    }

    interface def IfA006NormalLightRequest { end producer:NormalLightRequestOutputPort; end consumer:NormalLightRequestInputPort; flow producer.normalLightRequest to consumer.normalLightRequest; }
    interface def IfA006LightingAvailability { end producer:LightingAvailabilityOutputPort; end consumer:LightingAvailabilityInputPort; flow producer.lightingAvailability to consumer.lightingAvailability; }
    interface def IfA006LightModes { end producer:LightModesOutputPort; end consumer:LightModesInputPort; flow producer.lightModes to consumer.lightModes; }
}

package X2CityComponent_LightControl {
    private import X2CityContract_LightControl::*;
    private import X2CityComponent_LightModeSelection::*;
    private import X2CityComponent_LightActuation::*;
    private import X2CityContract_EnergyPath::*;
    private import X2CityContract_BrakeStateIdentification::*;
    private import X2CityContract_MotorControl::*;

    part def LightControl { // LE-LIGHT-CONTROL
        /* End-to-end lighting responsibility. It contains exactly the software mode-selection and hardware actuation responsibilities, receives qualified request/brake information plus distributed vehicle electrical energy, and provides physical illumination. */
        part lightModeSelection:LightModeSelection;
        part lightActuation:LightActuation;
        port runningLightStateIn:NormalLightRequestInputPort;
        port brakeLeverStateIn:BrakeLeverStateInputPort { doc /* Receives the qualified mechanical brake State/Qualification composite; it is not brake-force evidence. */ }
        port electricalBrakingStateIn:ElectricalBrakingStateInputPort { doc /* Receives Traction's qualified actual electrical-braking present/absent projection. */ }
        port lightingAvailabilityIn:LightingAvailabilityInputPort { doc /* Budget-derived operational constraint, delegated to actuation independently of mode selection. */ }
        port vehicleElectricalPowerIn:VehicleElectricalPowerInputPort { doc /* Receives distributed vehicle electrical energy from Energy for the contained actuation path. */ }
        port frontIlluminationOut:FrontIlluminationOutputPort;
        port rearIlluminationOut:RearIlluminationOutputPort;
        flow normalRequestToSelection from runningLightStateIn.normalLightRequest to lightModeSelection.runningLightStateIn.normalLightRequest;
        flow brakeLeverToSelection from brakeLeverStateIn.brakeLeverState to lightModeSelection.brakeLeverStateIn.brakeLeverState;
        flow electricalBrakingToSelection from electricalBrakingStateIn.payload to lightModeSelection.electricalBrakingStateIn.payload;
        interface selectedModesToActuation : IfA006LightModes
            connect lightModeSelection.lightModesOut to lightActuation.lightModesIn;
        flow lightingAvailabilityToActuation from lightingAvailabilityIn.lightingAvailability to lightActuation.lightingAvailabilityIn.lightingAvailability;
        flow vehicleElectricalPowerToActuation from vehicleElectricalPowerIn.vehicleElectricalPower to lightActuation.vehicleElectricalPowerIn.vehicleElectricalPower;
        flow frontIlluminationFromActuation from lightActuation.frontIlluminationOut.frontIllumination to frontIlluminationOut.frontIllumination;
        flow rearIlluminationFromActuation from lightActuation.rearIlluminationOut.rearIllumination to rearIlluminationOut.rearIllumination;
    }
}
