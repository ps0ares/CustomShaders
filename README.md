
# Custom Shaders 0.9

Custom Shaders is a LUA script for Open Broadcaster Software (OBS) that can be used to apply OBS effects to any image source. An OBS effect (or shader) is defined in a file with a nearly identical syntax to Direct3D 11 HLSL effect files.

## Why another effects add-on?

This script was inspired by the *filter-custom* included in [DarkLink's Script Pack](https://obsproject.com/forum/resources/darklinks-script-pack.655/) and builds upon the features provided by the [obs-shaderfilter](https://obsproject.com/forum/resources/obs-shaderfilter.775/) and the [OBS ShaderFilter Plus](https://obsproject.com/forum/resources/obs-shaderfilter-plus.929/) plugins.

## Installation

*Custom Shaders* is a single file script that can be placed anywhere in
your filesystem. Add it to OBS on the `Tools > Scripts` menu and it will
be ready to use.

## Usage

1.  Add a filter to a source by right-clicking a source, going to
    `Filters`, and adding `Custom Shader`.
2.  Select a shader by clicking the `Browse` button and picking the file
    containing the shader source code.
3.  Customize the behavior of the shader via the shader-specific user
    interface (UI).

Example shaders may be found in the [`examples`](examples) directory of
this repository. It is a good starting point for the creation of custom
effects.

![Demo](default.webp)

## What are Shaders?

Shaders are programs executed on the GPU. They can be used to apply
customizable special visual effects. The shaders used by this plugin are
a special subset of shaders called *fragment shaders*. These shaders are
executed once for each pixel of the source, every frame. See [Usage
Guide](#usage-guide) for examples.

Different graphics interfaces, such as OpenGL and DirectX, use different
shader languages with incompatible syntax, so it is important to be
aware of the graphics interfaces OBS makes use of.

-   OBS on Windows uses DirectX by default, but can be forced to use
    OpenGL.
-   OBS on Linux uses OpenGL.

Shaders are executed using OpenGL (GLSL shaders) or DirectX (HLSL
shaders), depending on your platform.

## Writing Cross-Platform Shaders

### Cross-Platform HLSL

When OBS is run with OpenGL, it performs primitive translation of HLSL
sources to GLSL. However, this translation is limited and performed via
basic string substitution, and therefore may not result in correct
behavior. Despite these limitations, cross platform shaders could be
written in HLSL, as long as they are simple.

### Cross-Platform GLSL

OBS on Windows may be forced to use OpenGL by launching the program with
the `--allow-opengl` [launch
parameter](https://obsproject.com/wiki/Launch-Parameters). This can be
done by creating a shortcut to the executable and appending the
parameter to the path, for example:
`"C:\Program Files\obs-studio\bin\64bit\obs64.exe" --allow-opengl`.
After launching OBS this way, the OpenGL renderer must be selected in
the Advanced Settings. After restarting OBS with these settings applied,
GLSL shaders will work properly.

## Installation

1.  Download the latest binary for your platform from [the Releases
    page](https://github.com/Limeth/obs-shaderfilter-plus/releases).

    -   On Windows, download the file ending with `_windows_x64.dll`
    -   On Linux, download the file ending with `_linux_x64.so`

2.  Place it in the OBS plugin directory:

    -   On Windows, that is usually
        `C:\Program Files\obs-studio\obs-plugins\64bit`
    -   On Linux, that is usually `/usr/lib/obs-plugins`

## Usage Guide {#usage-guide}

The structure of a shader is simple. All, that is required, is the
following `render` function.

``` {.hlsl}
float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    return image.Sample(builtin_texture_sampler, uv);
}
```

### Builtin Variables

Every shader loaded by this plugin has access to the following uniform
variables.

``` {.hlsl}
uniform texture2d image;                                     // the source texture (the image we are filtering)
uniform int       builtin_frame;                             // the current frame number
uniform float     builtin_framerate;                         // the current output framerate
uniform float     builtin_elapsed_time;                      // the current elapsed time
uniform float     builtin_elapsed_time_previous;             // the elapsed time in the previous frame
uniform float     builtin_elapsed_time_since_shown;          // the time since the source was shown
uniform float     builtin_elapsed_time_since_shown_previous; // the time since the source was shown of the previous frame
uniform int2      builtin_uv_size;                           // the source dimensions

sampler_state     builtin_texture_sampler { ... }; // a texture sampler with linear filtering
```

#### On-Request Builtin Variables

These uniform variables will be assigned data by the plugin. If they are
not defined, they do not use up processing resources.

``` {.hlsl}
uniform texture2d builtin_texture_fft_<NAME>;          // audio output frequency spectrum
uniform texture2d builtin_texture_fft_<NAME>_previous; // output from the previous frame (requires builtin_texture_fft_<NAME> to be defined)
```

Builtin FFT variables have specific properties. See the the section
below on properties.

Example:

``` {.hlsl}
#pragma shaderfilter set myfft__mix__description Main Mix/Track
#pragma shaderfilter set myfft__channel__description Main Channel
#pragma shaderfilter set myfft__dampening_factor_attack__step 0.0001
#pragma shaderfilter set myfft__dampening_factor_attack__default 0.05
#pragma shaderfilter set myfft__dampening_factor_release 0.0001
uniform texture2d builtin_texture_fft_myfft;
```

See the `examples` directory for more examples.

#### Custom Variables

These uniform variables may be used to let the user provide values to
the shader using the OBS UI. The allowed types are: \* `bool`: A boolean
variable \* `int`: A signed 32-bit integer variable \* `float`: A single
precision floating point variable \* `float4`/`vec4`: A color variable,
shown as a color picker in the UI

Example:

``` {.hlsl}
#pragma shaderfilter set my_color__description My Color
#pragma shaderfilter set my_color__default 7FFF00FF
uniform float4 my_color;
```

See the `examples` directory for more examples.

### Defining Properties in the Source Code

This plugin uses a simple preprocessor to process `#pragma shaderfilter`
macros. It is not a fully-featured C preprocessor. It is executed before
the shader is compiled. The shader compilation includes an actual C
preprocessing step. Do not expect to be able to use macros within
`#pragma shaderfilter`.

Most properties can be specified in the shader source code. The syntax
is as follows:

    #pragma shaderfilter set <PROPERTY> <VALUE>

#### Universal Properties

These properties can be applied to any user-defined uniform variable. \*
`default`: The default value of the uniform variable. \* `description`:
The user-facing text describing the variable. Displayed in the OBS UI.

#### Integer Properties

-   `min` (integer): The minimum allowed value
-   `max` (integer): The maximum allowed value
-   `step` (integer): The stride when changing the value
-   `slider` (true/false): Whether to display a slider or not

#### Float Properties

-   `min` (float): The minimum allowed value
-   `max` (float): The maximum allowed value
-   `step` (float): The stride when changing the value
-   `slider` (true/false): Whether to display a slider or not

#### FFT Properties

-   `mix`: The Mix/Track number corresponding to checkboxes in OBS'
    `Advanced Audio Properties`
-   `channel`: The channel number (0 = Left, 1 = Right for stereo)
-   `dampening_factor_attack`: The linear interpolation coefficient (in
    percentage) used to blend the previous FFT sample with the current
    sample, if it is larger than the previous
-   `dampening_factor_release`: The linear interpolation coefficient (in
    percentage) used to blend the previous FFT sample with the current
    sample, if it is lesser than the previous

## Planned Features

-   Access to raw audio signal, without FFT
-   Specifying textures by a path to an image file
