# Bms

`LE-BMS` represents the supplied JBD BMS assembly, including opaque vendor firmware. The model assigns it cell-bank monitoring, balancing, and protective switching, with physical cell-power, pack-power, series-group-tap, and available thermal-observation connections. Read-only UART request and telemetry ports connect the BMS to BatterySupervision. See [Bms.sysml](Bms.sysml) for the boundary and native allocation requirements.

Project software reads selected information through the modeled UART interface; the interface has no modeled write, override, or charger command. Detailed protocol and qualification evidence is documented with BatterySupervision in [BatterySupervision.md](../../BatterySupervision/BatterySupervision.md).
