# Gimp Resize RIS Plugin

GIMP plugin for resize images using Reverse Interpolate Scale (RIS)

This plugin is designed to resize images according to the RIS rules,
according to which an enlarged image can be returned
to the original image by simple averaging.

![RIS resize](images/ris-resize-dialog.png)

Hints:
 * The plugin is located in : Menu -> Image -> Transform -> Resize RIS
 * Currently it all colormode images

Compare:

Origin:  
![origin](images/means-orig.png)  
GIMP (cubic):  
![](images/means-gimp-cubic-x4.png)  
RIS resize (cubic):  
![RIS resize](images/means-ris-resize-x4.png)  


## Install:

Copy `resize-ris.py` in:
* Linux: `~/.gimp-2.8/plug-ins`
* Windows: `C:\Program Files\GIMP 2\lib\gimp\2.0\plug-ins`

----

Homepage: https://github.com/ImageProcessing-ElectronicPublications/gimp-plugin-resize-ris

2021
