fn main() {
    println!("cargo:rerun-if-changed=memory.x");
    println!("cargo:rerun-if-changed=memory-qspi.x");
    println!("cargo:rerun-if-env-changed=CARGO_FEATURE_QSPI_BOOT");

    let linker_script = if std::env::var_os("CARGO_FEATURE_QSPI_BOOT").is_some() {
        "memory-qspi.x"
    } else {
        "memory.x"
    };

    println!("cargo:rustc-link-arg=-T{linker_script}");
}
