*&---------------------------------------------------------------------*
*& Report Z_003_APPLY_STYLES_TO_CELL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_003_apply_styles_to_cell.

CLASS lcl_report DEFINITION.
*
  PUBLIC SECTION.
*
*   Final output table

    TYPES: BEGIN OF lty_spfli,
             carrid     TYPE spfli-carrid,
             connid     TYPE spfli-connid,
             cityfrom   TYPE spfli-cityfrom,
             airpfrom   TYPE spfli-airpfrom,
             cityto     TYPE spfli-cityto,
             airpto     TYPE spfli-airpto,
             distance   TYPE spfli-distance,
             i_celltype TYPE salv_t_int4_column,
           END OF lty_spfli.
    DATA: lt_spfli TYPE STANDARD TABLE OF lty_spfli.



*   ALV reference
    DATA: o_alv TYPE REF TO cl_salv_table.

    METHODS:
      get_data,           "  data selection
      generate_output.    "  Generating output
*
  PRIVATE SECTION.
    METHODS:
      set_columns.        "  Set columns
ENDCLASS.                    "lcl_report DEFINITION
*
*
START-OF-SELECTION.
  DATA: lo_report TYPE REF TO lcl_report.
*
  CREATE OBJECT lo_report.
  lo_report->get_data( ).
  lo_report->generate_output( ).


*
CLASS lcl_report IMPLEMENTATION.
*
  METHOD get_data.
*   data selection

    SELECT carrid
           connid
           cityfrom
           airpfrom
           cityto
           airpto
           distance
           INTO  CORRESPONDING FIELDS OF TABLE lt_spfli
           FROM  spfli
           UP TO 20 ROWS.

    FIELD-SYMBOLS: <lfs_vbak> LIKE LINE OF lt_spfli.
    DATA: lt_celltype TYPE salv_t_int4_column.
    DATA: ls_celltype LIKE LINE OF lt_celltype.
    LOOP AT lt_spfli ASSIGNING <lfs_vbak>.
      CLEAR: lt_celltype.
* Only VBELN for 2nd record
      IF <lfs_vbak>-distance >= '3000.000'.
        ls_celltype-columnname = ''.
        ls_celltype-value      = if_salv_c_cell_type=>hotspot.
        APPEND ls_celltype TO lt_celltype.
      ENDIF.

      IF sy-tabix = 2.
        ls_celltype-columnname = 'CARRID'.
        ls_celltype-value      = if_salv_c_cell_type=>hotspot.
        APPEND ls_celltype TO lt_celltype.
* Only ERDAT for 3rd record
      ELSEIF sy-tabix = 3.
        ls_celltype-columnname = 'CONNID'.
        ls_celltype-value      = if_salv_c_cell_type=>button.
        APPEND ls_celltype TO lt_celltype.
* Entire 5th record
      ELSEIF sy-tabix = 5.
        ls_celltype-columnname = ''.
        ls_celltype-value      = if_salv_c_cell_type=>hotspot.
        APPEND ls_celltype TO lt_celltype.
      ENDIF.
      <lfs_vbak>-i_celltype = lt_celltype.
    ENDLOOP.

  ENDMETHOD.                    "get_data
*
  METHOD generate_output.
* New ALV instance
    DATA: lx_msg TYPE REF TO cx_salv_msg.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = o_alv
          CHANGING
            t_table      = lt_spfli ).
      CATCH cx_salv_msg INTO lx_msg.
    ENDTRY.
*
* Setting up the Columns
    me->set_columns( ).

* Displaying the ALV
    o_alv->display( ).

  ENDMETHOD.                    "generate_output
*
  METHOD set_columns.
*
*...Get all the Columns
    DATA: lo_cols TYPE REF TO cl_salv_columns_table.
    lo_cols = o_alv->get_columns( ).
*
*   set the Column optimization
    lo_cols->set_optimize( 'X' ).

*   Set the Cell Type
    TRY.
        lo_cols->set_cell_type_column( 'I_CELLTYPE' ).
      CATCH cx_salv_data_error.                         "#EC NO_HANDLER
    ENDTRY.

  ENDMETHOD.                    "SET_COLUMNS

*
*
ENDCLASS.                    "lcl_report IMPLEMENTATION
