---
name: Serene Focus
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#454651'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#767682'
  outline-variant: '#c6c5d3'
  surface-tint: '#4b57aa'
  primary: '#142175'
  on-primary: '#ffffff'
  primary-container: '#2e3a8c'
  on-primary-container: '#9ea9ff'
  inverse-primary: '#bcc3ff'
  secondary: '#575e72'
  on-secondary: '#ffffff'
  secondary-container: '#dbe2fa'
  on-secondary-container: '#5d6478'
  tertiary: '#0c3225'
  on-tertiary: '#ffffff'
  tertiary-container: '#25493a'
  on-tertiary-container: '#90b7a4'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dfe0ff'
  primary-fixed-dim: '#bcc3ff'
  on-primary-fixed: '#000d60'
  on-primary-fixed-variant: '#333f91'
  secondary-fixed: '#dbe2fa'
  secondary-fixed-dim: '#bfc6dd'
  on-secondary-fixed: '#141b2c'
  on-secondary-fixed-variant: '#3f4759'
  tertiary-fixed: '#c3ecd7'
  tertiary-fixed-dim: '#a8cfbc'
  on-tertiary-fixed: '#002115'
  on-tertiary-fixed-variant: '#294e3f'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  margin-mobile: 16px
  margin-desktop: 48px
  gutter: 16px
---

## Brand & Style
The design system is centered on the concept of "Digital Zen." It aims to transform the chaotic nature of mobile notifications into a curated, calm experience. The target audience consists of knowledge workers, students, and individuals prone to digital overwhelm who require a tool that feels like a supportive assistant rather than another source of noise.

The visual style is **Minimalist Modern**. It prioritizes high legibility and intentional whitespace to lower cognitive load. By utilizing a "content-first" hierarchy and removing unnecessary decorative elements, the system ensures that the user's focus remains on the task at hand. The emotional response should be one of immediate relief, clarity, and regained control over one's digital environment.

## Colors
The palette is designed to induce a physiological state of focus and calm.
- **Primary (Deep Indigo):** Used for core branding, active states, and primary actions. It represents reliability and deep focus.
- **Secondary (Soft Blue):** Used for subtle backgrounds, secondary buttons, and grouping indicators. It provides a cooling effect to the UI.
- **Success (Mint Green):** Reserved for "Inbox Zero" states, completed tasks, and positive reinforcement when notifications are successfully filtered.
- **Neutral (Slate Grays):** A range of cool grays used for secondary text and borders to ensure the interface feels balanced and non-aggressive.
- **Background:** The default state uses a very light off-white (#FAFAFA) to reduce the harshness of pure white light.

## Typography
Inter is selected for its exceptional legibility on mobile screens and its neutral, systematic tone. 
- **Headlines:** Use a tighter letter-spacing and heavier weights to create clear entry points for the eye. 
- **Body Text:** Standard weight (400) is used for maximum readability during long-form scanning of notification logs.
- **Labels:** Used for metadata (timestamps, app names) and secondary information, often using the Indigo color to maintain brand presence without overwhelming the primary content.
- **Hierarchy:** Strict adherence to the scale ensures that even dense lists of notifications remain parsable.

## Layout & Spacing
The design system employs a **Fluid Grid** with a 4px baseline rhythm. 
- **Margins:** A standard 16px margin is maintained on mobile devices to prevent content from feeling cramped against the screen edges.
- **Vertical Rhythm:** Generous vertical padding (minimum 16px) is used between list items to prevent "touch-error" frustration and maintain a clean, airy feel.
- **Grouping:** Related settings or notifications should be grouped into cards with 12px internal padding and 16px external margins.
- **Breakpoints:** 
  - Mobile: < 600px (1 column)
  - Tablet: 600px - 1024px (2 columns for settings/dashboards)
  - Desktop: > 1024px (Max content width of 960px, centered).

## Elevation & Depth
To maintain a modern and calm aesthetic, this design system avoids heavy shadows. Depth is communicated through **Tonal Layers** and **Low-Contrast Outlines**.
- **Base Layer:** Background color (#FAFAFA).
- **Surface Layer:** White (#FFFFFF) cards or containers used for interactive content.
- **Elevation State:** Instead of shadows, use a 1px border (#E5E7EB) for inactive states. For "hover" or active states on mobile, a very soft, high-diffusion shadow (0px 4px 20px rgba(46, 58, 140, 0.05)) can be applied to give a floating sensation.
- **Overlays:** Use a 40% opacity Indigo tint for backdrops to keep the focus strictly on the active modal or dialogue.

## Shapes
The shape language is consistently **Rounded**. This softens the interface and reduces the "aggressive" feel of traditional data-heavy applications.
- **Buttons & Inputs:** Use the standard `rounded` (8px) setting.
- **Notification Cards:** Use `rounded-lg` (16px) to create a distinct, approachable container.
- **Interactive Toggles:** Use `rounded-xl` (24px) for the track to create a pill-shaped aesthetic that is familiar to mobile users.
- **Iconography:** Icons should feature rounded caps and corners (2px corner radius) to match the UI elements.

## Components
- **Notification List Items:** Feature the app icon on the left (rounded 8px), followed by the title and a two-line preview. Actionable swipe-gestures should reveal mint-green "Keep" or soft-gray "Filter" options.
- **Buttons:** 
  - *Primary:* Solid Deep Indigo with white text.
  - *Secondary:* Soft Blue background with Deep Indigo text.
- **Toggle Switches:** Use a pill-shaped design. The "On" state uses a soft Mint Green background to signal positive action/success, while the "Off" state uses a light gray.
- **Progress Indicators:** Linear, thin bars with rounded ends. Use a soft blue for the track and Deep Indigo for the progress fill.
- **Chips:** Used for filtering by app category (e.g., "Social," "Work," "Urgent"). These are pill-shaped with a 1px border and transition to a solid Soft Blue background when selected.
- **Input Fields:** Minimalist with a soft gray bottom border that transforms into a 2px Indigo border on focus. No heavy boxes.