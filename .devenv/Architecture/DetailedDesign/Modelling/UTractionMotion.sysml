package X2CityDetailedUnit_TractionMotion {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_TractionControl::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityDetailedUnit_PlatformContext::*;
    private import X2CityDetailedUnit_HallInterface::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    // Owner: SC-TRACTION-CTRL.V. This is the actual producer route for vehicle-motion facts.
    port def ElectricalPositionIn {
        doc /* Receives current Hall capture/position interpretation as the evidence input for speed, direction and standstill qualification. */
        in item payload:ElectricalPositionV1;
    }
    port def MotionCalibrationIn {
        doc /* Receives released map, pole-pair, final-drive, loaded-wheel and observability/standstill criteria for vehicle-motion interpretation. */
        in item payload:CalibrationBundleRecord;
    }
    port def MotionHealthIn {
        doc /* Receives Hall capture and position health; a capture fault, static state or absent edge alone cannot qualify standstill. */
        in item payload:SensorHealthConditionV1;
    }
    port def PlatformContextIn {
        doc /* Receives the platform context used to keep motion result and Hall evidence within one current vehicle/reset generation. */
        in item payload:PlatformContextRecord;
    }
    port def PlatformHealthIn {
        doc /* Receives platform health that makes the motion result unavailable when its observation function cannot be supported. */
        in item payload:PPltHealthOInformation;
    }
    port def QualifiedMotionOut {
        doc /* Publishes qualified vehicle speed, travel direction and standstill to Settings, Session, Demand and actual-output estimation independently of Ready or command acceptance. */
        out item payload:QualifiedMotionV1;
    }
    part def UTractionMotion {
        /* Publishes vehicle speed, direction and standstill independently of Ready and command
           acceptance, interpreting current Hall capture/position evidence only with current
           capture health, map/pole-pair/final-drive/loaded-wheel calibration and a released
           bounded-observability/standstill criterion. Static Hall state, an absent edge alone,
           command and PWM state produce unavailable, not standstill. */
        port electricalPositionIn:ElectricalPositionIn;
        port calibrationIn:MotionCalibrationIn;
        port motionHealthIn:MotionHealthIn;
        port platformContextIn:PlatformContextIn;
        port platformHealthIn:PlatformHealthIn;
        port qualifiedMotionOut:QualifiedMotionOut;
    }
}
