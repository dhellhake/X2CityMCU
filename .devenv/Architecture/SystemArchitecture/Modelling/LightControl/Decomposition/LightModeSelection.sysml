package X2CityComponent_LightModeSelection {
    private import X2CitySharedContracts::*;
    private import X2CityContract_LightControl::*;
    private import X2CityContract_Input::*;
    private import X2CityContract_MotorControl::*;

    part def LightModeSelection { // LE-LIGHT-POLICY
        /* Software responsibility for selecting Front Off/On and Rear Off/Dim/Full. It retains a valid normal request; it selects rear Full for qualified lever actuation, qualified actual electrical braking, or unavailable required brake information. It selects no physical drive, protection, or timer realization. */
        port runningLightStateIn:NormalLightRequestInputPort { doc /* Receives HMI's accepted On/Off request and qualification. */ }
        port brakeLeverStateIn:BrakeStateInputPort { doc /* Receives InputQualification's qualified mechanical brake-lever state; lever actuation is not measured brake force. */ }
        port electricalBrakingStateIn:ElectricalBrakingStateInputPort { doc /* Receives Traction's qualified actual electrical-braking present/absent projection, including rollback retardation and constant-speed descent control where present. */ }
        port lightModesOut:LightModesOutputPort { doc /* Publishes the composite Front/Rear selection and availability to hardware actuation. */ }
    }
}
