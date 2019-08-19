*&---------------------------------------------------------------------*
*& Report Z_100_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_100_ALV.

CLASS lcl_data DEFINITION DEFERRED.


*----------------------------------------------------------------------*
*       CLASS lcl_event_handler DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.

  PUBLIC SECTION.

    METHODS: handle_doubleclick FOR EVENT double_click
                       OF cl_salv_events_table
                           IMPORTING  row column.
ENDCLASS.





CLASS lcl_data DEFINITION.
  PUBLIC SECTION.
    DATA:
          mt_data TYPE spfli_tab,
          mt_sflight TYPE sflight.
    METHODS:
      get_data RETURNING VALUE(ro_data) TYPE REF TO lcl_data,
      get_fli IMPORTING iv_col TYPE data RETURNING VALUE(ro_data) TYPE REF TO lcl_data.
ENDCLASS.

CLASS lcl_data IMPLEMENTATION.
  METHOD get_data.
    SELECT * FROM spfli INTO CORRESPONDING FIELDS OF TABLE mt_data.
  ENDMETHOD.

  METHOD get_fli.
*    SELECT * FROM sflight INTO  mt_sflight WHERE connid = iv_col.
  ENDMETHOD.
ENDCLASS.




CLASS lcl_display DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      display ABSTRACT CHANGING it_data TYPE table.
ENDCLASS.

CLASS lcl_display_salv DEFINITION INHERITING FROM lcl_display.
  PUBLIC SECTION.
    METHODS:
      display REDEFINITION.
  PRIVATE SECTION.
    DATA: lr_alv TYPE REF TO cl_salv_table.
    DATA: lx_msg TYPE REF TO cx_salv_msg.
    DATA:
       gr_events TYPE REF TO cl_salv_events_table.
    DATA: o_event_handler TYPE REF TO lcl_event_handler.
ENDCLASS.

CLASS lcl_display_salv IMPLEMENTATION.
  METHOD display.
* New ALV instance
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = lr_alv
          CHANGING
            t_table      = it_data ).
      CATCH cx_salv_msg INTO lx_msg.
    ENDTRY.


  gr_events = lr_alv->get_event( ).

  CREATE OBJECT o_event_handler.
  SET HANDLER o_event_handler->handle_doubleclick FOR gr_events.

* Displaying the ALV
    lr_alv->display( ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_display_alv DEFINITION INHERITING FROM lcl_display.
  PUBLIC SECTION.
    METHODS:
      display REDEFINITION.
  PRIVATE SECTION.
    DATA:
          lr_alv TYPE REF TO cl_gui_alv_grid.
ENDCLASS.

CLASS lcl_display_alv IMPLEMENTATION.
  METHOD display.

  ENDMETHOD.
ENDCLASS.


CLASS lcl_event_handler IMPLEMENTATION.
  METHOD handle_doubleclick.
*    TABLES: spfli.
    DATA(df) = row.
    DATA(fg) = column.
    DATA lo_data TYPE REF TO lcl_data.
    CREATE OBJECT lo_data.
*    READ TABLE spfli INTO DATA(tab) INDEX row.
*    DATA(dfg) = lo_data->get_fli( iv_col = tab-connid ).
    MESSAGE: 'sdgefgs'  TYPE 'E'.
  ENDMETHOD.
ENDCLASS.





START-OF-SELECTION.
  DATA:
        lo_data TYPE REF TO lcl_data,
        lo_display TYPE REF TO lcl_display.

  CREATE OBJECT lo_data.
  lo_data->get_data( ).
*  DATA(rdg) = lo_data->mt_data.

  CREATE OBJECT lo_display TYPE lcl_display_salv.
  lo_display->display( CHANGING it_data = lo_data->mt_data ).


*  BREAK-POINT.
