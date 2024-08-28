# Multiple-Impact Shield
A shader and accompanying code for making shield effects that react to multiple impacts

### Built for Godot 4.x+

Based on concepts covered in this video: https://youtu.be/NeZcAYJdkv4


The core idea is simple: pass to the shader a uniform array of Vector4s representing impacts, use the xyz of this vector to refer to the location of the impact, and the w as a measure of the age of the impact.

The shader knows only these things, it's the responsibility of the shield object to add impacts to the array, and to decay them over time by modifying the w value.

From this information, the shader calculates the distance from the impact point to the fragment, and uses the age of the impact to determine the intensity of the impact at that point.

This is a great base for more complicated shield effects using the impact data calculated from this. I've only implimented it here in it's simplest form.
