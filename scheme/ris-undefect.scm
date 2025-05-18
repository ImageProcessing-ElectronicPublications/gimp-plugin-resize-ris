;
; (gimp-layer-set-mode layer-base SCREEN-MODE)
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

(define (ris-undefect image 
                    drawable
                    factor
                    method)
    (let*
        (
            (drawable  (car (gimp-image-active-drawable image)))
            (oldwidth  (car (gimp-image-width image)))
            (oldheight (car (gimp-image-height image)))
            (newwidth  (* oldwidth factor))
            (newheight (* oldheight factor))
            (layer-base (car (gimp-layer-copy drawable TRUE)))
            (layer-defect (car (gimp-layer-copy drawable TRUE)))
            (layer-copy (car (gimp-layer-copy drawable TRUE)))
        )
    
        (gimp-image-undo-group-start image)
    
        (gimp-context-set-interpolation method)

        (set! layer-base (car (gimp-layer-new-from-visible image image "visible")))
        (set! layer-defect (car (gimp-layer-copy layer-base TRUE)))
        (gimp-image-insert-layer image layer-base 0 -1)
        (gimp-image-insert-layer image layer-defect 0 -1)
        (gimp-layer-scale layer-defect newwidth newheight TRUE)
        (gimp-layer-scale layer-defect oldwidth oldheight TRUE)

        (set! layer-copy (car (gimp-layer-copy layer-base TRUE)))
        (gimp-image-insert-layer image layer-copy 0 -1)
        (gimp-layer-set-mode layer-copy GRAIN-EXTRACT-MODE)
        (set! layer-defect (car (gimp-image-merge-down image layer-copy EXPAND-AS-NECESSARY)))
        (gimp-layer-set-mode layer-defect GRAIN-EXTRACT-MODE)
        (set! layer-base (car (gimp-image-merge-down image layer-defect EXPAND-AS-NECESSARY)))
        (gimp-item-set-name layer-base "RISundefect")

        (gimp-displays-flush)
        
        (gimp-image-undo-group-end image)
    )
)

(script-fu-register "ris-undefect"
                    "_RIS undefect"
                    "Undefect based Resize used RIS (Reverse Interpolate Scale)"
                    "zvezdochiot https://github.com/zvezdochiot"
                    "This is free and unencumbered software released into the public domain."
                    "2025-05-18"
                    "*"
                    SF-IMAGE       "Image"       0
                    SF-DRAWABLE    "Drawable"    0
                    SF-VALUE       "Factor"      "0.5"
                    SF-ENUM        "Method"      '("InterpolationType" "cubic" "none" "linear" "cubic" "nohalo" "lohalo")
)

(script-fu-menu-register "ris-undefect" "<Image>/Image/Transform")
