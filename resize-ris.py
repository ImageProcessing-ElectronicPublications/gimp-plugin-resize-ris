###
### Gimp-Python - allows the writing of Gimp plugins in Python.
### Public Domain Mark 1.0
###  No Copyright
###

from gimpfu import *

PROC_NAME = 'python-fu-resize-ris'
PROC_LABEL = 'Resize RIS'
PROC_AUTHOR = 'zvezdochiot <zvezdochiot@sourceforge.net>'
PROC_DATE = '2021-03-10'

def ris(image, drawable, width, height, interpol):
    image.undo_group_start()
    orig_width = pdb.gimp_image_width(image)
    orig_height = pdb.gimp_image_height(image)

    copy_image = pdb.gimp_image_duplicate(image)
    copy_drawable = pdb.gimp_image_get_active_drawable(copy_image)
    blur_image = pdb.gimp_image_duplicate(image)
    blur_drawable = pdb.gimp_image_get_active_drawable(blur_image)

    pdb.gimp_context_set_interpolation(interpol)
    pdb.gimp_image_scale(blur_image, width, height)
    pdb.gimp_image_scale(blur_image, orig_width, orig_height)

    blur_layer = pdb.gimp_layer_new_from_visible(blur_image, image, "ResizeBlur")
    pdb.gimp_image_insert_layer(image, blur_layer, None, -1)
    pdb.gimp_image_set_active_layer(image, blur_layer)
    blur_layer.mode = SUBTRACT_MODE

    copy_layer = pdb.gimp_layer_new_from_visible(copy_image, image, "CopyOrig")
    pdb.gimp_image_insert_layer(image, copy_layer, None, -1)
    pdb.gimp_image_set_active_layer(image, copy_layer)
    copy_layer.mode = ADDITION_MODE

    blur_layer2 = pdb.gimp_layer_new_from_visible(blur_image, image, "ResizeBlur2")
    pdb.gimp_image_insert_layer(image, blur_layer2, None, -1)
    pdb.gimp_image_set_active_layer(image, blur_layer2)
    blur_layer2.mode = SUBTRACT_MODE

    copy_layer2 = pdb.gimp_layer_new_from_visible(copy_image, image, "CopyOrig2")
    pdb.gimp_image_insert_layer(image, copy_layer2, None, -1)
    pdb.gimp_image_set_active_layer(image, copy_layer2)
    copy_layer2.mode = ADDITION_MODE

    #pdb.gimp_image_merge_down(image, blur_layer, 0)

    pdb.gimp_image_delete(copy_image)
    pdb.gimp_image_delete(blur_image)

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
