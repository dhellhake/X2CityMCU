# BatteryAssembly
## Battery assembly

`LE-BATTERY-ASSEMBLY` is the removable pack composite containing the fixed Cells bank and supplied Bms. [BatteryAssembly.sysml](BatteryAssembly.sysml) defines their power, fourteen-series-group tap, thermal-observation, and protected pack-power connections.

The modeled boundary provides battery power to BatteryControl. BatteryAssembly.sysml declares the assembly integration requirement. Child composition requirements remain owned by Cells.sysml and Bms.sysml. BatteryControl and BatterySupervision own their respective additional integration and protocol documentation.
