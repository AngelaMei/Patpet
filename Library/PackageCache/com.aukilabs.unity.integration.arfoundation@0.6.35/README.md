# *Auki ARFoundation Integration*

This is a package aimed at Unity developers using the Auki SDK, for a more seamless integration with ARFoundation.

Example of usage (integrating with Manna):
```
var frameFeeder = manna.GetOrCreateFrameFeederComponent();
frameFeeder.AttachMannaInstance(manna);
```
or alternatively, if you place the  script yourself on `ArCameraManager` gameobject:
```
var frameFeeder = arCameraManager.gameobject.GetComponent<FrameFeederBase>();
frameFeeder.AttachMannaInstance(mannaInstance);
```
Or you are free to implement your own `CustomFeeder` by inheriting from `FrameFeederBase` and simply calling:
```
var frameFeeder = manna.GetOrCreateFrameFeederComponent<CustomFeeder>();
