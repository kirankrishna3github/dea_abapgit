*&---------------------------------------------------------------------*
*& Report Z_007_FACTORY_METH
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_007_factory_meth.

CLASS lcl_base_writer DEFINITION.
  PUBLIC SECTION.
    TYPE-POOLS : vrm.
    TYPES:
      ty_rep_type TYPE c LENGTH 1.
    CONSTANTS:
      gc_rep_pdf   TYPE ty_rep_type VALUE '1',
      gc_rep_write TYPE ty_rep_type VALUE '2',
      gc_rep_alv   TYPE ty_rep_type VALUE '3'.
*      gc_ukn       TYPE

    DATA gc_rep_type TYPE vrm_values. "TABLE OF ty_rep_type.
    DATA gv_rep_type LIKE LINE OF gc_rep_type.

    CLASS-METHODS:
      get_writer IMPORTING iv_rep_type      TYPE ty_rep_type DEFAULT gc_rep_write
                 RETURNING VALUE(ro_writer) TYPE REF TO lcl_base_writer
                 .
    METHODS:
      write_data, constructor.
ENDCLASS.

CLASS lcl_write_writer DEFINITION INHERITING FROM lcl_base_writer.
  PUBLIC SECTION.
    METHODS:
      write_data REDEFINITION.
ENDCLASS.

CLASS lcl_alv_writer DEFINITION INHERITING FROM lcl_base_writer.
  PUBLIC SECTION.
    METHODS:
      write_data REDEFINITION.
ENDCLASS.

CLASS lcl_pdf_writer DEFINITION INHERITING FROM lcl_base_writer.
  PUBLIC SECTION.
    METHODS:
      write_data REDEFINITION.
ENDCLASS.

CLASS lcl_unknown DEFINITION INHERITING FROM lcl_base_writer.
  PUBLIC SECTION.
    METHODS:
      write_data REDEFINITION.
ENDCLASS.


CLASS lcl_base_writer IMPLEMENTATION.
  METHOD constructor.
    CLEAR gc_rep_type.
*    DO 3 TIMES.
    gv_rep_type-key =  gc_rep_pdf.
    gv_rep_type-text = 'тип pdf_writer'.
    APPEND gv_rep_type TO gc_rep_type.
    gv_rep_type-key = gc_rep_write.
    gv_rep_type-text = 'тип write_writer'.
    APPEND gv_rep_type TO gc_rep_type.
    gv_rep_type-key = gc_rep_alv.
    gv_rep_type-text = 'тип alv_writer'.
    APPEND gv_rep_type TO gc_rep_type.
*    ENDDO.
      CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'P_TYPE'
      values = me->gc_rep_type.

  ENDMETHOD.

  METHOD get_writer.
    CASE iv_rep_type.
      WHEN gc_rep_pdf.
        CREATE OBJECT ro_writer TYPE lcl_pdf_writer.
      WHEN gc_rep_write.
        CREATE OBJECT ro_writer TYPE lcl_write_writer.
      WHEN gc_rep_alv.
        CREATE OBJECT ro_writer TYPE lcl_alv_writer.
      WHEN OTHERS.
        CREATE OBJECT ro_writer TYPE lcl_unknown.
    ENDCASE.
  ENDMETHOD.

  METHOD write_data.
    WRITE / 'Фабричный метод'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_write_writer IMPLEMENTATION.
  METHOD write_data.
    WRITE: / 'write'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_pdf_writer IMPLEMENTATION.
  METHOD write_data.
    WRITE: / 'pdf'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_alv_writer IMPLEMENTATION.
  METHOD write_data.
    WRITE: / 'alv'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_unknown IMPLEMENTATION.
  METHOD write_data.
    MESSAGE 'нет такого способа печати' TYPE 'S'.
    EXIT.
  ENDMETHOD.
ENDCLASS.

PARAMETERS p_type AS LISTBOX VISIBLE LENGTH 10 DEFAULT '2'.

 INITIALIZATION.
  DATA: lo_writer TYPE REF TO lcl_base_writer.
  CREATE OBJECT lo_writer.

START-OF-SELECTION.
  lo_writer = lcl_base_writer=>get_writer( p_type ).
  lo_writer->write_data( ).
