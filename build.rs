fn main() {
    // Cargo cannot infer linker-script dependencies from rustflags.
    println!("cargo:rerun-if-changed=memory.x");
}
