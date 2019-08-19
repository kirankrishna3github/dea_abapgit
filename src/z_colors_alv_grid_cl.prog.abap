*&---------------------------------------------------------------------*
*& Report Z_COLORS_ALV_GRID_CL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_colors_alv_grid_cl.

TABLES spfli.

TYPES: BEGIN OF lty_spfli,
         carrid   TYPE spfli-carrid,
         connid   TYPE spfli-connid,
         cityfrom TYPE spfli-cityfrom,
         airpfrom TYPE spfli-airpfrom,
         cityto   TYPE spfli-cityto,
         airpto   TYPE spfli-airpto,
         distance TYPE spfli-distance,
       END OF lty_spfli.

TYPES: BEGIN OF ty_s_data,
         carrid    TYPE spfli-carrid,
         connid    TYPE spfli-connid,
         cityfrom  TYPE spfli-cityfrom,
         airpfrom  TYPE spfli-airpfrom,
         cityto    TYPE spfli-cityto,
         airpto    TYPE spfli-airpto,
         distance  TYPE spfli-distance,
         linecolor TYPE lvc_t_scol,
       END OF ty_s_data.

*DATA: lt_spfli     TYPE STANDARD TABLE OF lty_spfli,
*      lv_index     TYPE i,
*      ls_color     TYPE lvc_s_scol,
*      lt_color     TYPE lvc_t_scol,
*      lt_data      TYPE TABLE OF ty_s_data,
*      ls_data      LIKE LINE OF lt_data
*      lr_alv       TYPE REF TO cl_salv_table,
*      lr_layout    TYPE REF TO cl_salv_layout,
*      ls_key       TYPE salv_s_layout_key,
*      lr_functions TYPE REF TO cl_salv_functions_list,
*      lr_columns   TYPE REF TO cl_salv_columns_table
*      ,gr_salv_dsp_set TYPE REF TO cl_salv_display_settings
.


*&---------------------------------------------------------------------*
*& Class lcl_display
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_display DEFINITION FINAL.
  PUBLIC SECTION.
    DATA table1 TYPE TABLE OF ty_s_data. "spfli_tab.
    DATA ev_c_id TYPE TABLE OF spfli-carrid.

    METHODS: display_salv CHANGING lt_data TYPE table,
      get_data IMPORTING iv_c_id TYPE table
               EXPORTING rt_tab  TYPE table.


ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_display
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_display IMPLEMENTATION.

  METHOD display_salv.

    DATA: lr_alv          TYPE REF TO cl_salv_table,
          lr_layout       TYPE REF TO cl_salv_layout,
          ls_key          TYPE salv_s_layout_key,
          lr_functions    TYPE REF TO cl_salv_functions_list,
          lr_columns      TYPE REF TO cl_salv_columns_table,
          gr_salv_dsp_set TYPE REF TO cl_salv_display_settings
          .

    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = lr_alv
      CHANGING
        t_table      = lt_data ).

    lr_layout = lr_alv->get_layout( ).

    ls_key-report = sy-repid.
    ls_key-handle = 'ALV1'.

    lr_layout->set_key( ls_key ).

    lr_layout->set_default( abap_true ).
    lr_layout->set_save_restriction( ).

    lr_functions = lr_alv->get_functions( ).
    lr_functions->set_all( abap_true ).

    "ZEBRA"
    gr_salv_dsp_set = lr_alv->get_display_settings( ).
    gr_salv_dsp_set->set_striped_pattern( 'X' ).
    gr_salv_dsp_set->set_list_header( 'БУП' ).

    lr_columns = lr_alv->get_columns( ).
    lr_columns->set_optimize( abap_true ).
    lr_columns->set_color_column( 'LINECOLOR' ).

    lr_alv->display( ).

  ENDMETHOD.

  METHOD get_data.

    DATA: lt_spfli TYPE STANDARD TABLE OF lty_spfli,
          lv_index TYPE i,
          ls_color TYPE lvc_s_scol,
          lt_color TYPE lvc_t_scol,
          lt_data  TYPE TABLE OF ty_s_data,
          ls_data  LIKE LINE OF lt_data.
    DATA c_id TYPE TABLE OF spfli-carrid.

    LOOP AT iv_c_id ASSIGNING FIELD-SYMBOL(<ls_c_id>).
      APPEND <ls_c_id> TO c_id.
    ENDLOOP.


*carrid
*             connid
*             cityfrom
*             airpfrom
*             cityto
*             airpto
*             distance

*      SELECT *
*             INTO  CORRESPONDING FIELDS OF TABLE lt_spfli
*             FROM  spfli
*             FOR ALL ENTRIES IN iv_c_id[]"c_id
*             WHERE carrid = iv_c_id."c_id-table_line.

      SELECT *
             INTO  CORRESPONDING FIELDS OF TABLE lt_spfli
             FROM  spfli
*             FOR ALL ENTRIES IN iv_c_id[]"c_id
             WHERE carrid IN iv_c_id."c_id-table_line.



    ls_color-color-col = 6.
    ls_color-color-int = 1.
    ls_color-color-inv = 1.
    ls_color-fname = 'DISTANCE'.

    APPEND ls_color TO lt_color.

*    MODIFY lt_spfli FROM @( value  #( distance = '2' ) ) . "WHERE distance = '0.0000'

    LOOP AT lt_spfli ASSIGNING FIELD-SYMBOL(<ls_spfli>).
      CLEAR: ls_data.

      ls_data-carrid    = <ls_spfli>-carrid  .
      ls_data-connid    = <ls_spfli>-connid   .
      ls_data-cityfrom  = <ls_spfli>-cityfrom .
      ls_data-airpfrom  = <ls_spfli>-airpfrom .
      ls_data-cityto    = <ls_spfli>-cityto   .
      ls_data-airpto    = <ls_spfli>-airpto   .
      ls_data-distance  = <ls_spfli>-distance .

      IF <ls_spfli>-distance = '0.0000'.
*        ls_data-linecolor-fname = 'DISTANCE'.
        ls_data-linecolor = lt_color.
      ENDIF.



      APPEND ls_data TO lt_data.
    ENDLOOP.

    rt_tab = lt_data.

  ENDMETHOD.

ENDCLASS.

DATA lt_c_id TYPE TABLE OF spfli-carrid.

START-OF-SELECTION.

  SELECT-OPTIONS pa_c_id FOR spfli-carrid NO INTERVALS.

END-OF-SELECTION.

DATA displ TYPE REF TO lcl_display.

CREATE OBJECT displ.

*  LOOP AT pa_c_id ASSIGNING FIELD-SYMBOL(<ls_c_id>).
*    APPEND <ls_c_id>-low TO lt_c_id.
*  ENDLOOP.

DATA lt_data TYPE TABLE OF ty_s_data.
displ->get_data( EXPORTING iv_c_id  = pa_c_id[] "lt_c_id
                 IMPORTING rt_tab   = lt_data ).

displ->display_salv( CHANGING lt_data = lt_data ).
