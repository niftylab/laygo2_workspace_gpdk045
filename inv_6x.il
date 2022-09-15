; laygo2 layout export skill script.

; laygo2 skill export script.
; - Initial code from BAG_framework (https://github.com/ucb-art/BAG_framework).
; - Users need to install CCSinvokeCdfCallbacks() from Cadence Online Support
;   (support.cadence.com) to enable pcell export.
;   (link: https://support.cadence.com/apex/ArticleAttachmentPortal?id=a1Od0000000namyEAA&pageName=ArticleContent)

; create or reset a library
procedure( _laygo2_reset_library(libname tech_libname "tt")
    let( (lib_obj cell)
        if( lib_obj = ddGetObj(libname nil nil nil nil "r") then
            ; if the library exists, delete all cells in the library
            foreach( cell lib_obj~>cells
                unless( ddDeleteObj(cell)
                    error("[LAYGO2] Cannot delete cell %s in library %s\n" cell~>name libname)
                );unless
            );foreach
            ddReleaseObj(lib_obj)
            't
        else
            ; create library if not exist
            lib_obj = ddCreateLib(libname)
            techBindTechFile(lib_obj tech_libname)  ; attach technology file
            ddReleaseObj(lib_obj)  ; close library
            't
        );if
    );let
);procedure

; create a new layout view and open it
procedure( _laygo2_open_layout(libname cellname viewname "tt")
    let( (cv)
        ; open layout cellview
        unless( cv = dbOpenCellViewByType( libname cellname viewname "maskLayout" "w" )
            error("[LAYGO2] Cannot create a new layout cell %s__%s (%s)." libname cellname viewname)
        ); unless
        printf("Created a layout %s__%s (%s)\n" libname cellname viewname)
    cv
    );let
);procedure

; create a new layout view and open it
procedure( _laygo2_save_and_close_layout(cv)
    dbSave(cv)
    dbClose(cv)
);procedure

; create an instance
procedure( _laygo2_generate_instance( cv name libname cellname viewname loc orient num_rows num_cols sp_rows sp_cols
                                      params params_order )
    let( (obj)
        if( inst_cv = dbOpenCellViewByType( libname cellname viewname nil "r" ) then  ; if the instance exists
            if( and( num_rows==1 num_cols==1 ) then  ; create a single instance
                if( params != nil then  ; for pcells
                    obj = dbCreateParamInst(cv inst_cv name loc orient 1 params)
                    when( obj
                        if( params_order == nil then  ; if parameter order is not specified,
                            params_order = mapcar( lambda( (x) car(x) ) params )
                        );if
                        ;abInvokeCdfCallbacks(obj ?order params_order)  ; run callback functions
                        CCSinvokeCdfCallbacks(obj ?order params_order)  ; run callback functions
                    );when
                else  ; for vanilla cells
                    obj = dbCreateInst(cv inst_cv name loc orient)
                );if
            else  ; create an array instance
                if( params != nil then  ; for pcells
                    obj = dbCreateParamSimpleMosaic(cv inst_cv name loc orient num_rows num_cols sp_rows sp_cols params)
                    when( obj
                        if( params_order == nil then  ; if parameter order is not specified,
                            params_order = mapcar( lambda( (x) car(x) ) params )
                        );if
                        ;abInvokeCdfCallbacks(obj ?order params_order)  ; run callback functions
                        CCSinvokeCdfCallbacks(obj ?order params_order)  ; run callback functions
                    );when
                else  ; for vanilla cells
                    obj = dbCreateSimpleMosaic(cv inst_cv name loc orient num_rows num_cols sp_rows sp_cols)
                );if
            );if
            unless( obj
                warn("[LAYGO2] Error creating an instance: %s of %s__%s (%s). Skipping." name libname cellname viewname)
            );unless
        else
            warn("[LAYGO2] Cannot find the instance %s__%s (%s). Skipping." libname cellname viewname)
        );if
        obj
    );let
);procedure

; create a rectangle
procedure( _laygo2_generate_rect( cv layer bbox color )
    ;obj = dbCreateRect(cv layer bbox)
    obj = dbCreateRect(cv layer bbox)
;    obj = dbSetShapeColor(dbCreateRect(cv layer bbox) color) ; coloring func. added
    if( color != "not MPT" then
        dbSetShapeColor( obj color )
        dbSetShapeColorLocked(obj t)
    else )
    obj
);procedure

; TODO: implement path creation function

; create a pin
procedure( _laygo2_generate_pin( cv, name, layer, bbox)
    let( (obj pin_w pin_h pin_xc pin_yc)
        pin_w = caadr(bbox) - caar(bbox)
        pin_h = cadr(cadr(bbox)) - cadr(car(bbox))
        pin_xc = (caar(bbox) + caadr(bbox)) / 2.0
        pin_yc = (cadr(car(bbox)) + cadr(cadr(bbox))) / 2.0
        if( pin_w >= pin_h then
            obj=dbCreateLabel( cv layer list(pin_xc pin_yc) name "centerCenter" "R0" "roman" pin_h )
        else
            obj=dbCreateLabel( cv layer list(pin_xc pin_yc) name "centerCenter" "R90" "roman" pin_w )
        ); if
    obj
    );let
);procedure

; test routine
let( (_laygo2_test cv)
    _laygo2_test = nil
    if( _laygo2_test then

        libname="test2"
        tech_libname="testtech"
        cellname="test"
        viewname="layout"

        name="MYINST0"
        inst_libname="test"
        inst_cellname="mytest"
        inst_viewname="layout"
        loc = list(10 20)
        orient="R0"
        num_rows=2
        num_cols=3
        sp_rows=2
        sp_cols=1
        params=nil
        params_order=nil

        rect_layer = list("M2" "drawing")
        rect_bbox = list(list(-5 -10) list(5 10))

        pin_name = "mypin"
        pin_layer = list("M2" "pin")
        pin_bbox = list(list(5 -10) list(15 10))

        _laygo2_reset_library(libname tech_libname)
        cv = _laygo2_open_layout(libname cellname viewname)
        _laygo2_generate_instance( cv name inst_libname inst_cellname inst_viewname loc orient num_rows num_cols sp_rows
                                sp_cols params params_order )
        _laygo2_generate_rect( cv rect_layer rect_bbox )
        _laygo2_generate_pin( cv, pin_name, pin_layer, pin_bbox)
        _laygo2_save_and_close_layout(cv)
    );if
);let


; exporting logic_generated__inv_6x
cv = _laygo2_open_layout("logic_generated" "inv_6x" "layout")
_laygo2_generate_instance(cv, "MN0_IBNDL0", "gpdk045_microtemplates_dense", "nmos4_fast_boundary", "layout", list( 0.0000  0.0000  ), "R0", 1, 1, 0, 0, nil, nil) ; for the Instance object MN0_IBNDL0 
_laygo2_generate_instance(cv, "MN0_IM0", "gpdk045_microtemplates_dense", "nmos4_fast_center_nf2", "layout", list( 0.2050  0.0000  ), "R0", 1, 3, 1.0000 , 0.4100 , nil, nil) ; for the Instance object MN0_IM0 
_laygo2_generate_instance(cv, "MN0_IBNDR0", "gpdk045_microtemplates_dense", "nmos4_fast_boundary", "layout", list( 1.4350  0.0000  ), "R0", 1, 1, 0, 0, nil, nil) ; for the Instance object MN0_IBNDR0 
_laygo2_generate_rect(cv, list( "Metal2" "drawing" ), list( list( 0.3450  0.7500  ) list( 1.2950  0.8300  ) ), "not MPT") ; for the Rect object MN0_RG0 
_laygo2_generate_instance(cv, "MN0_IVG0", "gpdk045_microtemplates_dense", "via_M1_M2_0", "layout", list( 0.4100  0.7900  ), "R0", 1, 3, 1.0000 , 0.4100 , nil, nil) ; for the Instance object MN0_IVG0 
_laygo2_generate_rect(cv, list( "Metal2" "drawing" ), list( list( 0.3450  0.4500  ) list( 1.2950  0.5300  ) ), "not MPT") ; for the Rect object MN0_RD0 
_laygo2_generate_instance(cv, "MN0_IVD0", "gpdk045_microtemplates_dense", "via_M1_M2_0", "layout", list( 0.4100  0.4900  ), "R0", 1, 3, 1.0000 , 0.4100 , nil, nil) ; for the Instance object MN0_IVD0 
_laygo2_generate_rect(cv, list( "Metal2" "drawing" ), list( list( -0.0400  -0.1200  ) list( 1.6800  0.1200  ) ), "not MPT") ; for the Rect object MN0_RRAIL0 
_laygo2_generate_rect(cv, list( "Metal1" "drawing" ), list( list( 0.1650  -0.0400  ) list( 0.2450  0.3800  ) ), "not MPT") ; for the Rect object MN0_RTIE0 
_laygo2_generate_rect(cv, list( "Metal1" "drawing" ), list( list( 0.5750  -0.0400  ) list( 0.6550  0.3800  ) ), "not MPT") ; for the Rect object MN0_RTIE1 
_laygo2_generate_rect(cv, list( "Metal1" "drawing" ), list( list( 0.9850  -0.0400  ) list( 1.0650  0.3800  ) ), "not MPT") ; for the Rect object MN0_RTIE2 
_laygo2_generate_rect(cv, list( "Metal1" "drawing" ), list( list( 1.3950  -0.0400  ) list( 1.4750  0.3800  ) ), "not MPT") ; for the Rect object MN0_RTIE3 
_laygo2_generate_instance(cv, "MN0_IVTIED0", "gpdk045_microtemplates_dense", "via_M1_M2_1", "layout", list( 0.2050  0.0000  ), "R0", 1, 4, 1.0000 , 0.4100 , nil, nil) ; for the Instance object MN0_IVTIED0 
_laygo2_generate_instance(cv, "MP0_IBNDL0", "gpdk045_microtemplates_dense", "pmos4_fast_boundary", "layout", list( 0.0000  2.0000  ), "MX", 1, 1, 0, 0, nil, nil) ; for the Instance object MP0_IBNDL0 
_laygo2_generate_instance(cv, "MP0_IM0", "gpdk045_microtemplates_dense", "pmos4_fast_center_nf2", "layout", list( 0.2050  2.0000  ), "MX", 1, 3, 1.0000 , 0.4100 , nil, nil) ; for the Instance object MP0_IM0 
_laygo2_generate_instance(cv, "MP0_IBNDR0", "gpdk045_microtemplates_dense", "pmos4_fast_boundary", "layout", list( 1.4350  2.0000  ), "MX", 1, 1, 0, 0, nil, nil) ; for the Instance object MP0_IBNDR0 
_laygo2_generate_rect(cv, list( "Metal2" "drawing" ), list( list( 0.3450  1.2500  ) list( 1.2950  1.1700  ) ), "not MPT") ; for the Rect object MP0_RG0 
_laygo2_generate_instance(cv, "MP0_IVG0", "gpdk045_microtemplates_dense", "via_M1_M2_0", "layout", list( 0.4100  1.2100  ), "MX", 1, 3, 1.0000 , 0.4100 , nil, nil) ; for the Instance object MP0_IVG0 
_laygo2_generate_rect(cv, list( "Metal2" "drawing" ), list( list( 0.3450  1.5500  ) list( 1.2950  1.4700  ) ), "not MPT") ; for the Rect object MP0_RD0 
_laygo2_generate_instance(cv, "MP0_IVD0", "gpdk045_microtemplates_dense", "via_M1_M2_0", "layout", list( 0.4100  1.5100  ), "MX", 1, 3, 1.0000 , 0.4100 , nil, nil) ; for the Instance object MP0_IVD0 
_laygo2_generate_rect(cv, list( "Metal2" "drawing" ), list( list( -0.0400  2.1200  ) list( 1.6800  1.8800  ) ), "not MPT") ; for the Rect object MP0_RRAIL0 
_laygo2_generate_rect(cv, list( "Metal1" "drawing" ), list( list( 0.1650  2.0400  ) list( 0.2450  1.6200  ) ), "not MPT") ; for the Rect object MP0_RTIE0 
_laygo2_generate_rect(cv, list( "Metal1" "drawing" ), list( list( 0.5750  2.0400  ) list( 0.6550  1.6200  ) ), "not MPT") ; for the Rect object MP0_RTIE1 
_laygo2_generate_rect(cv, list( "Metal1" "drawing" ), list( list( 0.9850  2.0400  ) list( 1.0650  1.6200  ) ), "not MPT") ; for the Rect object MP0_RTIE2 
_laygo2_generate_rect(cv, list( "Metal1" "drawing" ), list( list( 1.3950  2.0400  ) list( 1.4750  1.6200  ) ), "not MPT") ; for the Rect object MP0_RTIE3 
_laygo2_generate_instance(cv, "MP0_IVTIED0", "gpdk045_microtemplates_dense", "via_M1_M2_1", "layout", list( 0.2050  2.0000  ), "MX", 1, 4, 1.0000 , 0.4100 , nil, nil) ; for the Instance object MP0_IVTIED0 
_laygo2_generate_rect(cv, list( "Metal2" "drawing" ), list( list( 0.1650  0.7500  ) list( 0.4500  0.8300  ) ), "not MPT") ; for the Rect object NoName_0 
_laygo2_generate_instance(cv, "NoName_1", "gpdk045_microtemplates_dense", "via_M2_M3_0", "layout", list( 0.2050  0.7900  ), "R0", 1, 1, 0, 0, nil, nil) ; for the Instance object NoName_1 
_laygo2_generate_rect(cv, list( "Metal2" "drawing" ), list( list( 0.1650  1.1700  ) list( 0.4500  1.2500  ) ), "not MPT") ; for the Rect object NoName_2 
_laygo2_generate_instance(cv, "NoName_3", "gpdk045_microtemplates_dense", "via_M2_M3_0", "layout", list( 0.2050  1.2100  ), "R0", 1, 1, 0, 0, nil, nil) ; for the Instance object NoName_3 
_laygo2_generate_rect(cv, list( "Metal3" "drawing" ), list( list( 0.1650  0.7500  ) list( 0.2450  1.2500  ) ), "not MPT") ; for the Rect object NoName_4 
_laygo2_generate_instance(cv, "NoName_5", "gpdk045_microtemplates_dense", "via_M2_M3_0", "layout", list( 1.2300  0.4900  ), "R0", 1, 1, 0, 0, nil, nil) ; for the Instance object NoName_5 
_laygo2_generate_rect(cv, list( "Metal3" "drawing" ), list( list( 1.1900  0.4500  ) list( 1.2700  1.5500  ) ), "not MPT") ; for the Rect object NoName_6 
_laygo2_generate_instance(cv, "NoName_7", "gpdk045_microtemplates_dense", "via_M2_M3_0", "layout", list( 1.2300  1.5100  ), "R0", 1, 1, 0, 0, nil, nil) ; for the Instance object NoName_7 
_laygo2_generate_rect(cv, list( "Metal2" "drawing" ), list( list( -0.0400  -0.1200  ) list( 1.6800  0.1200  ) ), "not MPT") ; for the Rect object NoName_8 
_laygo2_generate_rect(cv, list( "Metal2" "drawing" ), list( list( -0.0400  1.8800  ) list( 1.6800  2.1200  ) ), "not MPT") ; for the Rect object NoName_9 
_laygo2_generate_pin(cv, "I", list( "Metal3" "pin" ), list( list( 0.1650  0.7900  ) list( 0.2450  1.2100  ) ) ) ; for the Pin object I 
_laygo2_generate_pin(cv, "O", list( "Metal3" "pin" ), list( list( 1.1900  0.4900  ) list( 1.2700  1.5100  ) ) ) ; for the Pin object O 
_laygo2_generate_pin(cv, "VSS", list( "Metal2" "pin" ), list( list( 0.0000  -0.1200  ) list( 1.6400  0.1200  ) ) ) ; for the Pin object VSS 
_laygo2_generate_pin(cv, "VDD", list( "Metal2" "pin" ), list( list( 0.0000  1.8800  ) list( 1.6400  2.1200  ) ) ) ; for the Pin object VDD 
_laygo2_save_and_close_layout(cv)
