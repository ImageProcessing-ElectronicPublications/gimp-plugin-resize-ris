(define (resize-ris image 
                    drawable
                    newwidth
                    newheight
                    method)
    (let*
        (
            (drawable  (car (gimp-image-active-drawable image)))
            (oldwidth  (car (gimp-image-width image)))
            (oldheight (car (gimp-image-height image)))
            (new-layer-1 (car (gimp-layer-copy drawable TRUE)))
            (new-layer-2 (car (gimp-layer-copy drawable TRUE)))
            (new-layer-3 (car (gimp-layer-copy drawable TRUE)))
        )
    
        (gimp-image-undo-group-start image)
    
        (gimp-image-insert-layer image new-layer-1 0 -1)
        (gimp-image-insert-layer image new-layer-2 0 -1)
        (gimp-layer-set-mode new-layer-2 LAYER-MODE-MULTIPLY-LEGACY)
        (set! new-layer-1 (car (gimp-image-merge-down image new-layer-2 EXPAND-AS-NECESSARY)))

        (cond
            ((= method 0)
                (gimp-context-set-interpolation INTERPOLATION-CUBIC)
            )
            ((= method 1)
                (gimp-context-set-interpolation INTERPOLATION-NONE)
            )
            ((= method 2)
                (gimp-context-set-interpolation INTERPOLATION-LINEAR)
            )
            ((= method 3)
                (gimp-context-set-interpolation INTERPOLATION-CUBIC)
            )
            ((= method 4)
                (gimp-context-set-interpolation INTERPOLATION-NOHALO)
            )
            ((= method 5)
                (gimp-context-set-interpolation INTERPOLATION-LOHALO)
            )
        )

        (gimp-image-insert-layer image new-layer-3 0 -1)
        (gimp-layer-scale new-layer-3 newwidth newheight TRUE)
        (gimp-layer-scale new-layer-3 oldwidth oldheight TRUE)

        (gimp-layer-set-mode new-layer-3 LAYER-MODE-DIVIDE-LEGACY)
        (set! new-layer-1 (car (gimp-image-merge-down image new-layer-3 EXPAND-AS-NECESSARY)))
        (gimp-item-set-name new-layer-1 "RIS")

        (gimp-image-scale image newwidth newheight)

        (gimp-displays-flush)
        
        (gimp-image-undo-group-end image)
    )
)

(script-fu-register "resize-ris"
                    "_Resize RIS"
                    "Resize used RIS (Reverse Interpolate Scale)"
                    "zvezdochiot https://github.com/zvezdochiot"
                    "This is free and unencumbered software released into the public domain."
                    "2025-02-05"
                    "*"
                    SF-IMAGE       "Image"       0
                    SF-DRAWABLE    "Drawable"    0
                    SF-VALUE       "Width"       "1024"
                    SF-VALUE       "Height"      "1024"
                    SF-OPTION      "Method"      '("Cubic" "None" "Linear" "Cubic" "NoHalo" "LowHalo")
)

(script-fu-menu-register "resize-ris" "<Image>/Image/Transform")
