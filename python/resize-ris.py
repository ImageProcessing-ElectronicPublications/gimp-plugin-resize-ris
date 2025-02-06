###
### Gimp-Python - allows the writing of Gimp plugins in Python.
### Public Domain Mark 1.0
###  No Copyright
###

from gimpfu import *

PROC_NAME = 'python-fu-resize-ris'
PROC_LABEL = 'Resize RIS'
PROC_AUTHOR = 'zvezdochiot <zvezdochiot@sourceforge.net>'
PROC_DATE = '2021-03-13'

def ris(image, drawable, width, height, interpol):
    image.undo_group_start()
    orig_width = pdb.gimp_image_width(image)
    orig_height = pdb.gimp_image_height(image)

    image_copy = pdb.gimp_image_duplicate(image)
    drawable_copy = pdb.gimp_image_get_active_drawable(image_copy)
    image_blur = pdb.gimp_image_duplicate(image)
    drawable_blur = pdb.gimp_image_get_active_drawable(image_blur)

    pdb.gimp_context_set_interpolation(interpol)
    pdb.gimp_image_scale(image_blur, width, height)
    pdb.gimp_image_scale(image_blur, orig_width, orig_height)

    layer_blur = pdb.gimp_layer_new_from_visible(image_blur, image, "ResizeBlur")
    pdb.gimp_image_insert_layer(image, layer_blur, None, -1)
    pdb.gimp_image_set_active_layer(image, layer_blur)

    layer_copy = pdb.gimp_layer_new_from_visible(image_copy, image, "CopyOrig")
    pdb.gimp_image_insert_layer(image, layer_copy, None, -1)
    pdb.gimp_image_set_active_layer(image, layer_copy)
    layer_copy.mode = SUBTRACT_MODE

    layer_sub = pdb.gimp_image_merge_down(image, layer_copy, 0)
    layer_sub.name = "RIS_SUBTRACT"
    layer_sub.mode = SUBTRACT_MODE

    layer_copy = pdb.gimp_layer_new_from_visible(image_copy, image, "CopyOrig")
    pdb.gimp_image_insert_layer(image, layer_copy, None, -1)
    pdb.gimp_image_set_active_layer(image, layer_copy)

    layer_blur = pdb.gimp_layer_new_from_visible(image_blur, image, "ResizeBlur")
    pdb.gimp_image_insert_layer(image, layer_blur, None, -1)
    pdb.gimp_image_set_active_layer(image, layer_blur)
    layer_blur.mode = SUBTRACT_MODE

    layer_plus = pdb.gimp_image_merge_down(image, layer_blur, 0)
    layer_plus.name = "RIS_ADDITION"
    layer_plus.mode = ADDITION_MODE

    pdb.gimp_image_delete(image_copy)
    pdb.gimp_image_delete(image_blur)

    pdb.gimp_image_scale(image, width, height)

    pdb.gimp_displays_flush()
    image.undo_group_end()

register(
    PROC_NAME,
    PROC_LABEL,
    "",
    PROC_AUTHOR,
    PROC_AUTHOR,
    PROC_DATE,
    PROC_LABEL,
    "*",
    [
        (PF_IMAGE, "image", "_Image", None),
        (PF_LAYER, "drawable", "_Drawable", None),
        (PF_INT,    "width",    "Width",         512),
        (PF_INT,    "height",   "Height",        512),
        (PF_OPTION, "interp",   "Method",        2, ["None","Linear","Cubic","Lanczos"]),
        #(PF_FLOAT,  "mult",     "Multiply",      1),
    ],
    [],
    ris,
    menu="<Image>/Image/Transform",
    domain=("gimp20-python", gimp.locale_directory))

main()
