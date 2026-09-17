package X2CityDetailedUnit_TractionMotion {
    private import X2CitySharedSoftwareTypes::*;
    private import X2CitySoftwareContract_TractionControl::*;
    private import X2CitySoftwareContract_Platform::*;
    private import X2CityDetailedUnit_PlatformContext::*;
    private import X2CityDetailedUnit_HallInterface::*;
    private import X2CityDetailedUnit_PlatformCalibration::*;
    private import X2CitySoftwareContract_HallInterface::*;
    // Owner: SC-TRACTION-CTRL.V. This is the actual producer route for vehicle-motion facts.
    port def ElectricalPositionInputPort {
        doc /* Receives current Hall capture/position interpretation as the evidence input for speed, direction and standstill qualification. */
        in item payload:HallElectricalPosition;
    }
    port def MotionCalibrationInputPort {
        doc /* Receives released map, pole-pair, final-drive, loaded-wheel and observability/standstill criteria for vehicle-motion interpretation. */
        in item payload:ActiveCalibrationBundle;
    }
    port def MotionHealthInputPort {
        doc /* Receives Hall capture and position health; a capture fault, static state or absent edge alone cannot qualify standstill. */
        in item payload:SensorHealthCondition;
    }
    port def PlatformContextInputPort {
        doc /* Receives the platform context used to keep motion result and Hall evidence within one current vehicle/reset generation. */
        in item payload:PlatformContext;
    }
    port def PlatformHealthInputPort {
        doc /* Receives platform health that makes the motion result unavailable when its observation function cannot be supported. */
        in item payload:PlatformHealth;
    }
    port def QualifiedMotionOutputPort {
        doc /* Publishes qualified vehicle speed, travel direction and standstill to Settings, Session, Demand and actual-output estimation independently of Ready or command acceptance. */
        out item payload:QualifiedMotion;
    }
    part def VehicleMotionEstimator {
        /* Publishes vehicle speed, direction and standstill independently of Ready and command
           acceptance, interpreting current Hall capture/position evidence only with current
           capture health, map/pole-pair/final-drive/loaded-wheel calibration and a released
           bounded-observability/standstill criterion. Static Hall state, an absent edge alone,
           command and PWM state produce unavailable, not standstill. */
        port electricalPositionIn:ElectricalPositionInputPort;
        port calibrationIn:MotionCalibrationInputPort;
        port motionHealthIn:MotionHealthInputPort;
        port platformContextIn:PlatformContextInputPort;
        port platformHealthIn:PlatformHealthInputPort;
        port qualifiedMotionOut:QualifiedMotionOutputPort;
    }
}
