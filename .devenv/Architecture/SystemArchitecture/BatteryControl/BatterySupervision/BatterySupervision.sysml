package X2CityComponent_BatterySupervision {
    private import X2CityContract_BatteryControl::*;
    attribute def BatteryVoltageDeratingCalibration {
        doc /*
            Endpoints in volts per series group: discharge uses Vl and regeneration uses Vh.
        */
        attribute dischargeFullCurrentVoltageVolts:Real {
            doc /*
                Discharge voltage factor is 1; other constraints may reduce final current.
            */
        }
        attribute dischargeCutoffVoltageVolts:Real {
            doc /*
                Discharge voltage factor is 0.
            */
        }
        attribute regenerativeFullCurrentVoltageVolts:Real {
            doc /*
                Regenerative voltage factor is 1; other constraints may reduce final current.
            */
        }
        attribute regenerativeCutoffVoltageVolts:Real {
            doc /*
                Regenerative voltage factor is 0.
            */
        }
    }

    part def BatterySupervision { // LE-BATTERY-SUPERVISION
        doc /*
            Vehicle-host logical responsibility for reading and qualifying BMS information, capability and
            operating policy. Software realization is pending; supplied BMS internals remain outside it.
        */
        attribute voltageDeratingCalibration:BatteryVoltageDeratingCalibration {
            doc /*
                Immutable compiled calibration set; these current values await product validation.
            */
            :>> dischargeFullCurrentVoltageVolts = 3.40;
            :>> dischargeCutoffVoltageVolts = 3.10;
            :>> regenerativeFullCurrentVoltageVolts = 4.00;
            :>> regenerativeCutoffVoltageVolts = 4.10;
        }
        port bmsTelemetryIn:BmsTelemetryInputPort {
            doc /*
                Read-only UART response input from the supplied BMS.
            */
        }
        port bmsReadRequestOut:BmsReadRequestOutputPort {
            doc /*
                Read-only UART request output to the supplied BMS.
            */
        }
        port batteryStatusOut:BatteryStatusOutputPort {
            doc /*
                Publishes independent battery reporting conditions including lowDischargeVoltageWarning;
                operating qualification and effective limits travel on BatteryOperatingLimits.
            */
        }
        port batteryOperatingLimitsOut:BatteryOperatingLimitsOutputPort {
            doc /*
                Publishes independent charge/discharge assessments for RidingControl budgeting and
                EnergyPath enforcement of total battery bounds.
            */
        }
        port stateOfChargeOut:BatteryStateOfChargeOutputPort {
            doc /*
                Publishes qualified actual SOC to HMI for display and range information.
            */
        }
        port batteryCurrentOut:BatteryCurrentOutputPort {
            doc /*
                Publishes independently qualified signed pack current in amperes to
                RidingControl.CurrentConsumptionCoordination and HMIControl.
            */
        }
    }

}
