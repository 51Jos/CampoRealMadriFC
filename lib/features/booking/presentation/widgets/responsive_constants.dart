/// Constantes y utilidades para diseño responsivo
enum ScreenBreakpoint {
  mobile,        // < 600px
  tablet,        // 600px - 900px
  desktop,       // 900px - 1200px
  largeDesktop,  // > 1200px
}

class ResponsiveUtils {
  static ScreenBreakpoint getBreakpoint(double width) {
    if (width < 600) return ScreenBreakpoint.mobile;
    if (width < 900) return ScreenBreakpoint.tablet;
    if (width < 1200) return ScreenBreakpoint.desktop;
    return ScreenBreakpoint.largeDesktop;
  }

  static double getPadding(ScreenBreakpoint breakpoint) {
    switch (breakpoint) {
      case ScreenBreakpoint.mobile:
        return 16.0;
      case ScreenBreakpoint.tablet:
        return 24.0;
      case ScreenBreakpoint.desktop:
        return 32.0;
      case ScreenBreakpoint.largeDesktop:
        return 40.0;
    }
  }

  static double getSpacing(ScreenBreakpoint breakpoint) {
    switch (breakpoint) {
      case ScreenBreakpoint.mobile:
        return 12.0;
      case ScreenBreakpoint.tablet:
        return 16.0;
      case ScreenBreakpoint.desktop:
        return 20.0;
      case ScreenBreakpoint.largeDesktop:
        return 24.0;
    }
  }

  static double getTitleSize(ScreenBreakpoint breakpoint) {
    switch (breakpoint) {
      case ScreenBreakpoint.mobile:
        return 20.0;
      case ScreenBreakpoint.tablet:
        return 22.0;
      case ScreenBreakpoint.desktop:
        return 24.0;
      case ScreenBreakpoint.largeDesktop:
        return 26.0;
    }
  }

  static double getSubtitleSize(ScreenBreakpoint breakpoint) {
    switch (breakpoint) {
      case ScreenBreakpoint.mobile:
        return 16.0;
      case ScreenBreakpoint.tablet:
        return 17.0;
      case ScreenBreakpoint.desktop:
        return 18.0;
      case ScreenBreakpoint.largeDesktop:
        return 19.0;
    }
  }

  static double getBodySize(ScreenBreakpoint breakpoint) {
    switch (breakpoint) {
      case ScreenBreakpoint.mobile:
        return 14.0;
      case ScreenBreakpoint.tablet:
        return 14.5;
      case ScreenBreakpoint.desktop:
        return 15.0;
      case ScreenBreakpoint.largeDesktop:
        return 15.5;
    }
  }

  static double getButtonSize(ScreenBreakpoint breakpoint) {
    switch (breakpoint) {
      case ScreenBreakpoint.mobile:
        return 12.0;
      case ScreenBreakpoint.tablet:
        return 13.0;
      case ScreenBreakpoint.desktop:
        return 14.0;
      case ScreenBreakpoint.largeDesktop:
        return 14.5;
    }
  }

  static double getMaxContentWidth(ScreenBreakpoint breakpoint) {
    switch (breakpoint) {
      case ScreenBreakpoint.mobile:
        return double.infinity;
      case ScreenBreakpoint.tablet:
        return 800;
      case ScreenBreakpoint.desktop:
        return 1200;
      case ScreenBreakpoint.largeDesktop:
        return 1400;
    }
  }
}
