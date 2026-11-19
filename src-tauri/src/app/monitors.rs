//! Monitor geometry helpers.
//!
//! All rectangles and points here are expressed in **physical** pixels in the
//! global virtual-desktop coordinate space, which is what both `rdev` and
//! `tauri::Monitor` report. `x`/`y` may be negative for monitors placed left of
//! or above the primary one.
//!
//! Keeping this math in one place makes it unit-testable without spawning any
//! window, which matters because a wrong origin is exactly what used to make
//! clicks land on the wrong display (see issue #495).

/// A single monitor as a physical-pixel rectangle.
#[derive(Debug, Clone, PartialEq)]
pub struct MonitorRect {
    pub x: i32,
    pub y: i32,
    pub width: u32,
    pub height: u32,
    pub scale_factor: f64,
    /// Name reported by the window system; matches the settings selection.
    pub name: Option<String>,
}

impl MonitorRect {
    pub const fn new(x: i32, y: i32, width: u32, height: u32, scale_factor: f64) -> Self {
        Self {
            x,
            y,
            width,
            height,
            scale_factor,
            name: None,
        }
    }

    /// Attaches the monitor name reported by the window system.
    pub fn with_name(mut self, name: Option<String>) -> Self {
        self.name = name;
        self
    }

    pub fn right(&self) -> i32 {
        self.x + self.width as i32
    }

    pub fn bottom(&self) -> i32 {
        self.y + self.height as i32
    }

    /// Whether a global physical point falls inside this monitor.
    ///
    /// Bounds are half-open (`x`/`y` included, `right`/`bottom` excluded) so a
    /// point on the seam between two monitors belongs to exactly one of them.
    pub fn contains(&self, x: f64, y: f64) -> bool {
        x >= self.x as f64
            && x < self.right() as f64
            && y >= self.y as f64
            && y < self.bottom() as f64
    }

    /// Converts a global physical point into this monitor's local physical
    /// pixels, i.e. the coordinates an overlay window covering this monitor
    /// has to draw at.
    pub fn to_local(&self, x: f64, y: f64) -> (f64, f64) {
        to_local((self.x, self.y), x, y)
    }

    /// Squared distance from a global point to this monitor's centre. Used as
    /// a tie-breaker when the point is on no monitor at all.
    fn distance_sq(&self, x: f64, y: f64) -> f64 {
        let centre_x = self.x as f64 + self.width as f64 / 2.0;
        let centre_y = self.y as f64 + self.height as f64 / 2.0;

        (x - centre_x).powi(2) + (y - centre_y).powi(2)
    }
}

/// Subtracts a monitor's global origin from a global physical point.
pub fn to_local(origin: (i32, i32), x: f64, y: f64) -> (f64, f64) {
    (x - origin.0 as f64, y - origin.1 as f64)
}

/// Index of the monitor a global physical point belongs to.
///
/// When the point sits on no monitor (a gap between displays, or a cursor
/// pushed slightly past the desktop edge) the nearest monitor by centre
/// distance wins, so a click is never silently dropped.
pub fn monitor_at(monitors: &[MonitorRect], x: f64, y: f64) -> Option<usize> {
    monitors
        .iter()
        .position(|monitor| monitor.contains(x, y))
        .or_else(|| {
            monitors
                .iter()
                .enumerate()
                .min_by(|(_, a), (_, b)| a.distance_sq(x, y).total_cmp(&b.distance_sq(x, y)))
                .map(|(index, _)| index)
        })
}

#[cfg(test)]
mod tests {
    use super::*;

    /// 1920x1080 @100% at the origin, 2560x1440 @125% to its right.
    fn side_by_side() -> [MonitorRect; 2] {
        [
            MonitorRect::new(0, 0, 1920, 1080, 1.0),
            MonitorRect::new(1920, 0, 2560, 1440, 1.25),
        ]
    }

    #[test]
    fn contains_hits_each_monitor() {
        let [left, right] = side_by_side();

        assert!(left.contains(0.0, 0.0));
        assert!(left.contains(1919.0, 1079.0));
        assert!(!left.contains(1920.0, 0.0));

        assert!(!right.contains(1919.0, 0.0));
        assert!(right.contains(1920.0, 0.0));
        assert!(right.contains(4479.0, 1439.0));
    }

    #[test]
    fn seam_belongs_to_the_monitor_on_its_right() {
        let [left, right] = side_by_side();

        assert!(!left.contains(1920.0, 540.0));
        assert!(right.contains(1920.0, 540.0));
    }

    #[test]
    fn coordinates_are_local_to_the_monitor_origin() {
        let [left, right] = side_by_side();

        assert_eq!(left.to_local(100.0, 200.0), (100.0, 200.0));
        // A click near the top-left corner of the right monitor must stay a
        // small number instead of drifting into the thousands.
        assert_eq!(right.to_local(1930.0, 210.0), (10.0, 210.0));
    }

    #[test]
    fn negative_origin_is_supported() {
        // Monitor placed to the left of the primary: negative virtual x.
        let monitor = MonitorRect::new(-1600, 0, 1600, 900, 1.0);

        assert!(monitor.contains(-1600.0, 0.0));
        assert!(monitor.contains(-1.0, 899.0));
        assert!(!monitor.contains(0.0, 0.0));
        assert_eq!(monitor.to_local(-1500.0, 100.0), (100.0, 100.0));
    }

    #[test]
    fn monitor_above_the_primary_gets_negative_y() {
        let monitor = MonitorRect::new(0, -1080, 1920, 1080, 1.0);

        assert!(monitor.contains(10.0, -1070.0));
        assert!(!monitor.contains(10.0, 0.0));
        assert_eq!(monitor.to_local(10.0, -1000.0), (10.0, 80.0));
    }

    #[test]
    fn fractional_pixels_are_preserved() {
        // rdev reports f64 coordinates; truncating them would make the ring
        // jitter by a pixel on high-refresh input devices.
        assert_eq!(to_local((1920, 0), 1930.5, 42.25), (10.5, 42.25));
    }

    #[test]
    fn scale_factor_is_carried_but_not_applied_here() {
        // Conversion to CSS pixels is the webview's job: every overlay window
        // inherits its monitor's DPR, so this helper must not scale anything.
        let monitor = MonitorRect::new(1920, 0, 2560, 1440, 1.25);

        assert_eq!(monitor.scale_factor, 1.25);
        assert_eq!(monitor.to_local(1920.0, 0.0), (0.0, 0.0));
    }

    #[test]
    fn monitor_at_finds_the_monitor_under_the_pointer() {
        let monitors = side_by_side();

        assert_eq!(monitor_at(&monitors, 10.0, 10.0), Some(0));
        assert_eq!(monitor_at(&monitors, 3000.0, 900.0), Some(1));
        assert_eq!(monitor_at(&[], 0.0, 0.0), None);
    }

    #[test]
    fn corner_to_corner_layout_routes_each_click_to_its_own_display() {
        // Layout used to reproduce issue #495 on Windows: a 1920x1200 primary
        // at 125% and an 800x600 display above its right edge. They touch
        // corner to corner, so the pointer can only reach the second one by
        // jumping, which is exactly the case a single overlay window missed.
        let monitors = [
            MonitorRect::new(0, 0, 1920, 1200, 1.25),
            MonitorRect::new(1920, -600, 800, 600, 1.0),
        ];

        assert_eq!(monitor_at(&monitors, 960.0, 600.0), Some(0));
        assert_eq!(monitor_at(&monitors, 2320.0, -300.0), Some(1));

        // The click on the second display must stay local, otherwise the ring
        // is drawn outside the window and gets clipped again.
        assert_eq!(monitors[1].to_local(2320.0, -300.0), (400.0, 300.0));
        assert_eq!(monitors[0].to_local(960.0, 600.0), (960.0, 600.0));

        // The right of the primary is a gap: the nearest centre still owns it.
        assert_eq!(monitor_at(&monitors, 2400.0, 100.0), Some(1));
    }

    #[test]
    fn monitor_at_never_drops_a_point_between_displays() {
        // 100 px gap: the pointer is on neither monitor, but the event still
        // has to be drawn somewhere, on the closest one.
        let monitors = [
            MonitorRect::new(0, 0, 1000, 1000, 1.0),
            MonitorRect::new(1100, 0, 1000, 1000, 1.0),
        ];

        assert_eq!(monitor_at(&monitors, 1020.0, 500.0), Some(0));
        assert_eq!(monitor_at(&monitors, 1080.0, 500.0), Some(1));
        assert_eq!(monitor_at(&monitors, 100.0, 5000.0), Some(0));
    }
}
