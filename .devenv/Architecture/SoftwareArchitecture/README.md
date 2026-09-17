# Vehicle Software Architecture

`ARCH-003_Software_Architecture.md` is the vehicle static architecture and `Runtime_Integration_Contract.md` is its selected vehicle runtime allocation. Load `../SystemArchitecture/Modelling` for logical supertypes, then `Modelling` for shared software types and root composition, and each component folder for its component model and recursive `DetailedDesign` resources. The entry package is `X2CitySoftwareArchitecture`.

The model contains only vehicle V instances. `SharedSoftwareTypes.sysml` holds common context/qualification records. `DetailedDesign/Modelling` holds shared detailed contracts and the detailed-design composition root; component `DetailedDesign` folders hold their owned unit models and Markdown design. Supplied BMS and VD18MT components remain opaque and therefore have no vendor-internal detailed design.
