;
; (gimp-layer-set-mode layer-copy SCREEN-MODE)
; NORMAL-MODE 0
; DISSOLVE-MODE 1
; BEHIND-MODE 2
; MULTIPLY-MODE 3
; SCREEN-MODE 4
; OVERLAY-MODE 5
; DIFFERENCE 6
; ADDITION-MODE 7
; SUBTRACT-MODE 8
; DARKEN-ONLY-MODE 9
; LIGHTEN-ONLY-MODE10
; HUE-MODE 11
; SATURATION-MODE 12
; COLOR-MODE 13
; VALUE-MODE 14
; DIVIDE-MODE 15
; DODGE-MODE 16
; BURN-MODE 17
; HARDLIGHT-MODE 18
; SOFTLIGHT-MODE 19
; GRAIN-EXTRACT-MODE 20
; GRAIN-MERGE-MODE 21
; COLOR-ERASE-MODE 22

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
            (layer-copy (car (gimp-layer-copy drawable TRUE)))
            (layer-defect (car (gimp-layer-copy drawable TRUE)))
            (new-layer-1 (car (gimp-layer-copy drawable TRUE)))
            (new-layer-2 (car (gimp-layer-copy drawable TRUE)))
            (new-layer-3 (car (gimp-layer-copy drawable TRUE)))
        )
    
        (gimp-image-undo-group-start image)
    
        (gimp-context-set-interpolation method)

        (set! layer-copy (car (gimp-layer-new-from-visible image image "visible")))
        (set! layer-defect (car (gimp-layer-copy layer-copy TRUE)))
        (gimp-image-insert-layer image layer-copy 0 -1)
        (gimp-image-insert-layer image layer-defect 0 -1)
        (gimp-layer-scale layer-defect newwidth newheight TRUE)
        (gimp-layer-scale layer-defect oldwidth oldheight TRUE)

        (set! new-layer-1 (car (gimp-layer-copy layer-copy TRUE)))
        (set! new-layer-2 (car (gimp-layer-copy layer-copy TRUE)))
        (set! new-layer-3 (car (gimp-layer-copy layer-defect TRUE)))
        (gimp-image-insert-layer image new-layer-1 0 -1)
        (gimp-image-insert-layer image new-layer-2 0 -1)
        (gimp-image-insert-layer image new-layer-3 0 -1)
        (gimp-layer-set-mode new-layer-1 SUBTRACT-MODE)
        (set! layer-defect (car (gimp-image-merge-down image new-layer-1 EXPAND-AS-NECESSARY)))
        (gimp-layer-set-mode new-layer-3 SUBTRACT-MODE)
        (set! new-layer-2 (car (gimp-image-merge-down image new-layer-3 EXPAND-AS-NECESSARY)))
        (gimp-layer-set-mode layer-defect SUBTRACT-MODE)
        (set! layer-copy (car (gimp-image-merge-down image layer-defect EXPAND-AS-NECESSARY)))
        (gimp-layer-set-mode new-layer-2 ADDITION-MODE)
        (set! layer-copy (car (gimp-image-merge-down image new-layer-2 EXPAND-AS-NECESSARY)))
        (gimp-item-set-name layer-copy "RIS")

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
                    "2025-02-07"
                    "*"
                    SF-IMAGE       "Image"       0
                    SF-DRAWABLE    "Drawable"    0
                    SF-VALUE       "Width"       "1024"
                    SF-VALUE       "Height"      "1024"
                    SF-ENUM        "Method"      '("InterpolationType" "cubic" "none" "linear" "cubic" "nohalo" "lohalo")
)

(script-fu-menu-register "resize-ris" "<Image>/Image/Transform")
