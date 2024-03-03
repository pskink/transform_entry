# transform_entry

This package contains classes for dealing with `Matrix4` in a simple way, similar to how `RSTransform.fromComponents` works.

It provides:

* `composeMatrix` - a low level function for creating `Matrix4` objects
* `TransformEntry` - a transform consisting of a translation, a rotation, and a uniform scale
* `TransformEntryTween` - a `Tween` for `TransformEntry` class
* `AnimatedTransformEntry` - an animated `Widget` that applies a transform defined by `TransformEntry` to a child `Widget`

## Example

Check [example](example) folder for some code samples
