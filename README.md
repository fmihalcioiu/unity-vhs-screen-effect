# VHS Screen Effect

A full-screen VHS look for Unity's Universal Render Pipeline: red and blue pulled apart, scanlines that drift, a glitch band and posterize.

## Contents

| File | What it is |
|---|---|
| `Shaders/ScreenVHSEffects.shader` | The full-screen shader. It shows up as `com.vhs_screen_effect/ScreenVHSEffects` in a material's shader menu. |
| `Runtime/UnscaledShaderTimeDriver.cs` | Feeds the shader unscaled time, so the effect keeps moving while `Time.timeScale` is 0. It creates itself before the first scene loads, so you don't add it to anything. |
| `Materials/ScreenVHSEffects_Mat.mat` | A subtle preset with a light split and faint scanlines. The glitch band and posterize are off in it. |

## Requirements

Unity 6000.4 or newer, with the Universal Render Pipeline as the project's render pipeline. The package doesn't list URP as a dependency, so installing it never adds URP to a project that doesn't use it.

## Install

In the Package Manager, choose + > Install package from git URL and enter:

```
https://github.com/fmihalcioiu/unity-vhs-screen-effect.git
```

Or add this line to `Packages/manifest.json`:

```json
"com.vhs-screen-effect": "https://github.com/fmihalcioiu/unity-vhs-screen-effect.git"
```

## Setup

Add a Full Screen Pass Renderer Feature to the Universal Renderer Data asset your URP asset uses. Set its Pass Material to `ScreenVHSEffects_Mat` or to your own material with the shader. Fetch Color Buffer has to be on, because the shader reads the camera image from it.

The packaged material is read-only. To change its values, duplicate it into your Assets folder and use the copy.

## Material settings

| Setting | What it does |
|---|---|
| Split Amount | How far the red and blue channels move apart. |
| Direction | Which way they move. |
| Scanline Intensity | How dark the scanlines are. |
| Scanline Density | How many scanlines cover the screen height. |
| Scanline Drift Speed | How fast the scanlines roll. |
| Glitch Jitter | How far lines inside the glitch band shift sideways. At 0 the band is off. |
| Glitch Speed | How fast the band moves through the picture and its lines wobble. |
| Posterize Levels | How many colour levels each channel keeps. |
| Posterize Blend | How much of the posterized image is mixed in. At 0 posterize is off. |

## Unscaled time

The driver sets a global shader vector, `_UnscaledTimeParams`, from `Time.unscaledTime` every frame. Its `y` is the unscaled time in seconds. Your own shaders can read it as well.

## Licence

MIT. See [LICENSE.md](LICENSE.md).
