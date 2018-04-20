// x11-rs: Rust bindings for X11 libraries
// The X11 libraries are available under the MIT license.
// These bindings are public domain.

extern crate pkg_config;

use std::env;
use std::fs::File;
use std::io::Write;
use std::path::Path;

fn main() {
    let libraries = ["xext",
                     "gl",
                     "xcursor",
                     "xxf86vm",
                     "xft",
                     "xinerama",
                     "xi",
                     "x11",
                     "xlib_xcb",
                     "xmu",
                     "xrandr",
                     "xtst",
                     "xrender",
                     "xscrnsaver",
                     "xt"];

    let mut config = String::new();
    for lib in libraries.iter() {
        let libdir = match pkg_config::get_variable(lib, "libdir") {
            Ok(libdir) => format!("Some(\"{}\")", libdir),
            Err(_) => "None".to_string(),
        };
        config.push_str(&format!("pub const {}: Option<&'static str> = {};\n", lib, libdir));
    }
    let config = format!("pub mod config {{ pub mod libdir {{\n{}}}\n}}", config);
    let out_dir = env::var("OUT_DIR").unwrap();
    let dest_path = Path::new(&out_dir).join("config.rs");
    let mut f = File::create(&dest_path).unwrap();
    f.write_all(&config.into_bytes()).unwrap();

    let target = env::var("TARGET").unwrap();
    if target.contains("linux") {
        println!("cargo:rustc-link-lib=dl");
    } else if target.contains("freebsd") || target.contains("dragonfly") {
        println!("cargo:rustc-link-lib=c");
    }
}
