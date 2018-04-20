#![cfg(any(target_os = "android"))]

pub use winit::os::android::{WindowBuilderExt, WindowExt};

pub use api::egl::ffi::EGLContext;

use {Context, HeadlessContext};
use os::GlContextExt;

impl GlContextExt for Context {
    type Handle = EGLContext;

    #[inline]
    unsafe fn raw_handle(&self) -> Self::Handle {
        self.context.raw_handle()
    }
}

impl GlContextExt for HeadlessContext {
    type Handle = EGLContext;

    #[inline]
    unsafe fn raw_handle(&self) -> Self::Handle {
        self.context.raw_handle()
    }
}
