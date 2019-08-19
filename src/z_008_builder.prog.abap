*&---------------------------------------------------------------------*
*& Report Z_008_BUILDER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_008_BUILDER.

PARAMETERS: p_list TYPE abap_bool RADIOBUTTON GROUP 1,
            p_grid TYPE abap_bool RADIOBUTTON GROUP 1.

CLASS lcl_alv_builder DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      setup_display_options ABSTRACT,
      setup_functions ABSTRACT,
      get_alv RETURNING VALUE(ro_alv) TYPE REF TO cl_salv_table.
  PROTECTED SECTION.
    DATA: mo_alv TYPE REF TO cl_salv_table.
ENDCLASS.

CLASS lcl_list_alv_builder DEFINITION INHERITING FROM lcl_alv_builder.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING ir_table TYPE REF TO data,
      setup_display_options REDEFINITION,
      setup_functions REDEFINITION.
ENDCLASS.

CLASS lcl_grid_alv_builder DEFINITION INHERITING FROM lcl_alv_builder.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING ir_table TYPE REF TO data,
      setup_display_options REDEFINITION,
      setup_functions REDEFINITION.
ENDCLASS.

CLASS lcl_alv_maker DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING io_alv_builder TYPE REF TO lcl_alv_builder,
      construct_alv RETURNING VALUE(ro_alv) TYPE REF TO cl_salv_table.
  PRIVATE SECTION.
    DATA:
          mo_builder TYPE REF TO lcl_alv_builder.
ENDCLASS.

*&---------------------------------------------------------------------*
*&  Реализация классов
*&---------------------------------------------------------------------*

CLASS lcl_alv_builder IMPLEMENTATION.
  METHOD get_alv.
    ro_alv = mo_alv.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_list_alv_builder IMPLEMENTATION.
  METHOD constructor.
    FIELD-SYMBOLS:
                   <lt_table> TYPE table.

    super->constructor( ).

    ASSIGN ir_table->* TO <lt_table>.
    CHECK sy-subrc = 0.

    TRY.
        cl_salv_table=>factory(
          EXPORTING
            list_display   = if_salv_c_bool_sap=>true
          IMPORTING
            r_salv_table   = mo_alv
          CHANGING
            t_table        = <lt_table>
        ).
      CATCH cx_salv_msg.
    ENDTRY.
  ENDMETHOD.

  METHOD setup_display_options.
    "Определение настроек
  ENDMETHOD.

  METHOD setup_functions.
    "Определение настроек функций
  ENDMETHOD.

ENDCLASS.

CLASS lcl_grid_alv_builder IMPLEMENTATION.
  METHOD constructor.
    FIELD-SYMBOLS:
                   <lt_table> TYPE table.

    super->constructor( ).

    ASSIGN ir_table->* TO <lt_table>.
    CHECK sy-subrc = 0.

    TRY.
        cl_salv_table=>factory(
          EXPORTING
            list_display   = if_salv_c_bool_sap=>false
          IMPORTING
            r_salv_table   = mo_alv
          CHANGING
            t_table        = <lt_table>
        ).
      CATCH cx_salv_msg.
    ENDTRY.
  ENDMETHOD.

  METHOD setup_display_options.
    "Определение настроек
  ENDMETHOD.

  METHOD setup_functions.
    "Определение настроек функций
  ENDMETHOD.

ENDCLASS.

CLASS lcl_alv_maker IMPLEMENTATION.
  METHOD constructor.
    mo_builder = io_alv_builder.
  ENDMETHOD.

  METHOD construct_alv.
    mo_builder->setup_display_options( ).
    mo_builder->setup_functions( ).
    ro_alv = mo_builder->get_alv( ).
  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  DATA:
        lo_alv_maker TYPE REF TO lcl_alv_maker,
        lo_alv_builder TYPE REF TO lcl_alv_builder,
        lt_table TYPE TABLE OF spfli,
        lr_table TYPE REF TO data.

  SELECT * FROM spfli INTO CORRESPONDING FIELDS OF TABLE lt_table.
  GET REFERENCE OF lt_table INTO lr_table.

  CASE abap_true.
    WHEN p_list.
      CREATE OBJECT lo_alv_builder TYPE lcl_list_alv_builder EXPORTING ir_table = lr_table.
    WHEN p_grid.
      CREATE OBJECT lo_alv_builder TYPE lcl_grid_alv_builder EXPORTING ir_table = lr_table.
  ENDCASE.

  CREATE OBJECT lo_alv_maker EXPORTING io_alv_builder = lo_alv_builder.

  lo_alv_maker->construct_alv( )->display( ).
