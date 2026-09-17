# DD-001 — Software unit design: SettingsPolicy

### U-SET-STATE

Consumes qualified current-context VD18MT requests and coherent qualified standstill/physical-accelerator-rest evidence. It retains distinct requested, pending and active state. On an interpretable speed request `r`, it applies the parent normalization `N.r)=r` for `0<r<40` km/h and `N.r)=40` for `r=0` or `r>=40`; unrecognized input changes neither valid active nor pending state. The latest valid pending settings apply atomically only when both guard facts hold. Active values remain otherwise, and active/pending speed never exceeds 40 km/h. After HMI loss, it may publish a current retained active-state snapshot with the original receipt provenance; HMI absence does not by itself age out a valid active selection or refresh the receipt. No received setting is inferred from initialization, retention, absence or an unqualified receipt.
