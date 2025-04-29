import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A collection of custom button widgets for the Taprobana Trails app

/// Primary button with customizable appearance
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.height = 50.0,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).primaryColor;
    final txtColor = textColor ?? Colors.white;
    
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 2.0,
          disabledBackgroundColor: bgColor.withOpacity(0.6),
          disabledForegroundColor: txtColor.withOpacity(0.6),
        ),
        child: isLoading
            ? SizedBox(
                height: 24.0,
                width: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: txtColor,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 18.0),
                      const SizedBox(width: 8.0),
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
      ),
    );
  }
}

/// Secondary button with outline style
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double height;
  final double borderRadius;
  final Color? borderColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.height = 50.0,
    this.borderRadius = 12.0,
    this.borderColor,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final bdColor = borderColor ?? primaryColor;
    final txtColor = textColor ?? primaryColor;
    
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: txtColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
          side: BorderSide(color: bdColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24.0,
                width: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: txtColor,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 18.0),
                      const SizedBox(width: 8.0),
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
      ),
    );
  }
}

/// Text button with optional icon
class TextActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? textColor;
  final double fontSize;
  final bool iconAfterText;

  const TextActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.textColor,
    this.fontSize = 14.0,
    this.iconAfterText = false,
  });

  @override
  Widget build(BuildContext context) {
    final txtColor = textColor ?? Theme.of(context).primaryColor;
    
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: txtColor,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: isLoading
          ? SizedBox(
              height: 16.0,
              width: 16.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: txtColor,
              ),
            )
          : icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: iconAfterText
                      ? [
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Icon(icon, size: fontSize + 2),
                        ]
                      : [
                          Icon(icon, size: fontSize + 2),
                          const SizedBox(width: 4.0),
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
    );
  }
}

/// Social sign-in button for authentication screens
class SocialButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool useOutline;

  const SocialButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    this.onPressed,
    this.isLoading = false,
    this.useOutline = true,
  });

  /// Factory for Google sign-in button
  factory SocialButton.google({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool useOutline = true,
  }) {
    return SocialButton(
      text: 'Continue with Google',
      icon: FontAwesomeIcons.google,
      color: Colors.red,
      onPressed: onPressed,
      isLoading: isLoading,
      useOutline: useOutline,
    );
  }

  /// Factory for Apple sign-in button
  factory SocialButton.apple({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool useOutline = true,
  }) {
    return SocialButton(
      text: 'Continue with Apple',
      icon: FontAwesomeIcons.apple,
      color: Colors.black,
      onPressed: onPressed,
      isLoading: isLoading,
      useOutline: useOutline,
    );
  }

  /// Factory for Facebook sign-in button
  factory SocialButton.facebook({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool useOutline = true,
  }) {
    return SocialButton(
      text: 'Continue with Facebook',
      icon: FontAwesomeIcons.facebook,
      color: const Color(0xFF1877F2),
      onPressed: onPressed,
      isLoading: isLoading,
      useOutline: useOutline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      height: 50.0,
      width: double.infinity,
      child: useOutline
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                side: BorderSide(
                  color: isDarkMode ? Colors.white30 : Colors.black26,
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: _buildButtonContent(),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.white10 : Colors.white,
                foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                elevation: 1.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: _buildButtonContent(),
            ),
    );
  }

  Widget _buildButtonContent() {
    return isLoading
        ? const SizedBox(
            height: 24.0,
            width: 24.0,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(icon, color: color, size: 18.0),
              const SizedBox(width: 12.0),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
  }
}

/// Floating action button with customizable appearance
class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;
  final double size;
  final bool mini;
  final bool extended;
  final String? label;

  const ActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
    this.size = 56.0,
    this.mini = false,
    this.extended = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).primaryColor;
    final icoColor = iconColor ?? Colors.white;
    
    if (extended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: bgColor,
        foregroundColor: icoColor,
        tooltip: tooltip,
        elevation: 4.0,
        icon: Icon(icon),
        label: Text(label!),
      );
    }
    
    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        onPressed: onPressed,
        mini: mini,
        backgroundColor: bgColor,
        foregroundColor: icoColor,
        tooltip: tooltip,
        elevation: 4.0,
        child: Icon(icon),
      ),
    );
  }
}

/// Circular icon button with optional background
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;
  final bool hasShadow;
  final bool hasBorder;
  final Color? borderColor;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40.0,
    this.iconSize = 20.0,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
    this.hasShadow = false,
    this.hasBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? 
        (isDarkMode ? Colors.grey[800] : Colors.white);
    final icoColor = iconColor ?? 
        (isDarkMode ? Colors.white : Theme.of(context).primaryColor);
    final bdColor = borderColor ?? 
        (isDarkMode ? Colors.white24 : Colors.black12);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: hasBorder ? Border.all(color: bdColor, width: 1.0) : null,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: IconButton(
        icon: Icon(icon, size: iconSize),
        color: icoColor,
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: size,
          minHeight: size,
        ),
      ),
    );
  }
}

/// Toggle button for boolean states
class ToggleButton extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String activeText;
  final String inactiveText;
  final Color? activeColor;
  final Color? inactiveColor;
  final IconData? activeIcon;
  final IconData? inactiveIcon;
  final double height;
  final double borderRadius;

  const ToggleButton({
    super.key,
    required this.value,
    this.onChanged,
    this.activeText = 'ON',
    this.inactiveText = 'OFF',
    this.activeColor,
    this.inactiveColor,
    this.activeIcon,
    this.inactiveIcon,
    this.height = 40.0,
    this.borderRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final actvColor = activeColor ?? Theme.of(context).primaryColor;
    final inactvColor = inactiveColor ?? Colors.grey;
    
    return GestureDetector(
      onTap: () {
        if (onChanged != null) {
          onChanged!(!value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: value ? actvColor : inactvColor.withOpacity(0.2),
          border: Border.all(
            color: value ? actvColor : inactvColor,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (activeIcon != null && inactiveIcon != null) ...[
                Icon(
                  value ? activeIcon : inactiveIcon,
                  color: value ? Colors.white : inactvColor,
                  size: 16.0,
                ),
                const SizedBox(width: 4.0),
              ],
              Text(
                value ? activeText : inactiveText,
                style: TextStyle(
                  color: value ? Colors.white : inactvColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}