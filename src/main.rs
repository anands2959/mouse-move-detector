use std::sync::{Arc, Mutex};
use std::thread;
use std::time::{Duration, Instant};
use windows::{
    core::*,
    Win32::{
        Foundation::*,
        Graphics::Gdi::*,
        System::LibraryLoader::GetModuleHandleW,
        UI::{
            HiDpi::*,
            WindowsAndMessaging::*,
        },
    },
};

// Configuration constants
const SPEED_THRESHOLD: f64 = 800.0; // pixels per second
const OVERLAY_DURATION_MS: u64 = 900;
const CURSOR_SCALE_FACTOR: f32 = 3.0;
const POLLING_INTERVAL_MS: u64 = 16; // ~60 FPS

// Global state for the overlay window
static mut OVERLAY_WINDOW: HWND = HWND(0);
static mut OVERLAY_VISIBLE: bool = false;

// Shared state for mouse tracking
#[derive(Clone)]
struct MouseState {
    last_pos: (i32, i32),
    last_time: Instant,
    speed: f64,
}

impl Default for MouseState {
    fn default() -> Self {
        Self {
            last_pos: (0, 0),
            last_time: Instant::now(),
            speed: 0.0,
        }
    }
}

// Main application structure
struct MouseSpeedDetector {
    mouse_state: Arc<Mutex<MouseState>>,
    overlay_timer: Arc<Mutex<Option<Instant>>>,
}

impl MouseSpeedDetector {
    fn new() -> Self {
        Self {
            mouse_state: Arc::new(Mutex::new(MouseState::default())),
            overlay_timer: Arc::new(Mutex::new(None)),
        }
    }

    fn run(&self) -> Result<()> {
        println!("Starting mouse speed detector...");
        println!("Speed threshold: {} px/sec", SPEED_THRESHOLD);
        println!("Press Ctrl+C to exit");

        // Initialize the overlay window
        self.create_overlay_window()?;

        // Start the mouse monitoring thread
        let mouse_state = Arc::clone(&self.mouse_state);
        let overlay_timer = Arc::clone(&self.overlay_timer);
        
        thread::spawn(move || {
            let mut previous_time = Instant::now();
            
            // Get initial mouse position
            let mut point = POINT { x: 0, y: 0 };
            let mut previous_pos = unsafe {
                let _ = GetCursorPos(&mut point);
                (point.x, point.y)
            };

            loop {
                thread::sleep(Duration::from_millis(POLLING_INTERVAL_MS));
                
                // Get current mouse position
                let mut point = POINT { x: 0, y: 0 };
                unsafe {
                    if GetCursorPos(&mut point).is_err() {
                        continue;
                    }
                }

                let current_pos = (point.x, point.y);
                let current_time = Instant::now();
                
                // Calculate movement distance and time delta
                let dx = (current_pos.0 - previous_pos.0) as f64;
                let dy = (current_pos.1 - previous_pos.1) as f64;
                let distance = (dx * dx + dy * dy).sqrt();
                
                let time_delta = current_time.duration_since(previous_time).as_secs_f64();
                
                if time_delta > 0.0 {
                    let speed = distance / time_delta;
                    
                    // Update mouse state
                    if let Ok(mut state) = mouse_state.lock() {
                        state.last_pos = current_pos;
                        state.last_time = current_time;
                        state.speed = speed;
                    }
                    
                    // Check if speed exceeds threshold
                    if speed > SPEED_THRESHOLD {
                        println!("Fast movement detected: {:.1} px/sec", speed);
                        
                        // Show overlay
                        unsafe {
                            Self::show_overlay(current_pos);
                        }
                        
                        // Set timer for hiding overlay
                        if let Ok(mut timer) = overlay_timer.lock() {
                            *timer = Some(Instant::now());
                        }
                    }
                }
                
                previous_pos = current_pos;
                previous_time = current_time;
            }
        });

        // Start the overlay management thread
        let overlay_timer_clone = Arc::clone(&self.overlay_timer);
        thread::spawn(move || {
            loop {
                thread::sleep(Duration::from_millis(50));
                
                if let Ok(mut timer) = overlay_timer_clone.lock() {
                    if let Some(start_time) = *timer {
                        if start_time.elapsed().as_millis() as u64 >= OVERLAY_DURATION_MS {
                            unsafe {
                                Self::hide_overlay();
                            }
                            *timer = None;
                        }
                    }
                }
            }
        });

        // Keep the main thread alive and handle messages
        unsafe {
            let mut msg = MSG::default();
            loop {
                let result = GetMessageW(&mut msg, HWND(0), 0, 0);
                if result.0 == 0 || result.0 == -1 {
                    break;
                }
                TranslateMessage(&msg);
                DispatchMessageW(&msg);
            }
        }

        Ok(())
    }

    fn create_overlay_window(&self) -> Result<()> {
        unsafe {
            let instance = GetModuleHandleW(None)?;
            
            // Register window class
            let class_name = w!("MouseOverlayClass");
            let wc = WNDCLASSEXW {
                cbSize: std::mem::size_of::<WNDCLASSEXW>() as u32,
                style: CS_HREDRAW | CS_VREDRAW,
                lpfnWndProc: Some(overlay_window_proc),
                hInstance: instance.into(),
                hCursor: LoadCursorW(None, IDC_ARROW)?,
                hbrBackground: HBRUSH(0), // Transparent background
                lpszClassName: class_name,
                ..Default::default()
            };

            RegisterClassExW(&wc);

            // Create the overlay window
            OVERLAY_WINDOW = CreateWindowExW(
                WS_EX_LAYERED | WS_EX_TRANSPARENT | WS_EX_TOPMOST | WS_EX_TOOLWINDOW,
                class_name,
                w!("Mouse Speed Overlay"),
                WS_POPUP,
                0, 0, 100, 100,
                None,
                None,
                instance,
                None,
            );
            
            if OVERLAY_WINDOW.0 == 0 {
                return Err(Error::from_win32());
            }

            // Make the window layered and set transparency
            SetLayeredWindowAttributes(OVERLAY_WINDOW, COLORREF(0), 200, LWA_ALPHA)?;
        }

        Ok(())
    }

    unsafe fn show_overlay(mouse_pos: (i32, i32)) {
        if OVERLAY_WINDOW.0 == 0 {
            return;
        }

        let cursor_size = (32.0 * CURSOR_SCALE_FACTOR) as i32;
        let half_size = cursor_size / 2;

        // Position the overlay centered on the mouse cursor
        let _ = SetWindowPos(
            OVERLAY_WINDOW,
            HWND_TOPMOST,
            mouse_pos.0 - half_size,
            mouse_pos.1 - half_size,
            cursor_size,
            cursor_size,
            SWP_NOACTIVATE,
        );

        ShowWindow(OVERLAY_WINDOW, SW_SHOWNA);
        OVERLAY_VISIBLE = true;
    }

    unsafe fn hide_overlay() {
        if OVERLAY_WINDOW.0 != 0 && OVERLAY_VISIBLE {
            ShowWindow(OVERLAY_WINDOW, SW_HIDE);
            OVERLAY_VISIBLE = false;
        }
    }
}

// Window procedure for the overlay window
unsafe extern "system" fn overlay_window_proc(
    window: HWND,
    message: u32,
    wparam: WPARAM,
    lparam: LPARAM,
) -> LRESULT {
    match message {
        WM_PAINT => {
            let mut ps = PAINTSTRUCT::default();
            let hdc = BeginPaint(window, &mut ps);
            
            if !hdc.is_invalid() {
                // Get window dimensions
                let mut rect = RECT::default();
                let _ = GetClientRect(window, &mut rect);
                
                // Create a brush for the cursor color (bright red with some transparency)
                let brush = CreateSolidBrush(COLORREF(0x0000FF)); // Red color
                
                // Draw a circle to represent the enlarged cursor
                let center_x = rect.right / 2;
                let center_y = rect.bottom / 2;
                let radius = (rect.right.min(rect.bottom) / 2) - 2;
                
                // Create a pen for the outline
                let pen = CreatePen(PS_SOLID, 2, COLORREF(0x000080)); // Dark red outline
                let old_pen = SelectObject(hdc, pen);
                let old_brush = SelectObject(hdc, brush);
                
                // Draw the circle
                Ellipse(
                    hdc,
                    center_x - radius,
                    center_y - radius,
                    center_x + radius,
                    center_y + radius,
                );
                
                // Restore old objects and clean up
                SelectObject(hdc, old_pen);
                SelectObject(hdc, old_brush);
                DeleteObject(pen);
                DeleteObject(brush);
                
                EndPaint(window, &ps);
            }
            LRESULT(0)
        }
        WM_DESTROY => {
            PostQuitMessage(0);
            LRESULT(0)
        }
        _ => DefWindowProcW(window, message, wparam, lparam),
    }
}

fn main() -> Result<()> {
    println!("Mouse Speed Detector v1.0");
    println!("==========================");
    
    // Set DPI awareness for better cursor tracking
    unsafe {
        let _ = SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
    }

    let detector = MouseSpeedDetector::new();
    detector.run()?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_mouse_state_creation() {
        let state = MouseState::default();
        assert_eq!(state.last_pos, (0, 0));
        assert_eq!(state.speed, 0.0);
    }

    #[test]
    fn test_detector_creation() {
        let detector = MouseSpeedDetector::new();
        // Test that the detector is created successfully
        assert!(!detector.mouse_state.lock().is_err());
        assert!(!detector.overlay_timer.lock().is_err());
    }
}