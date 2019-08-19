*&---------------------------------------------------------------------*
*& Report Z_016_ITERATOR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_016_ITERATOR.

*&---------------------------------------------------------------------*
*&  Определение объектов / интерфейсов
*&---------------------------------------------------------------------*

INTERFACE lif_iterator.
  METHODS:
    first RETURNING VALUE(rs_spfli) TYPE spfli,
    next RETURNING VALUE(rs_spfli) TYPE spfli,
    is_done RETURNING VALUE(rv_done) TYPE abap_bool,
    current RETURNING VALUE(rs_spfli) TYPE spfli.
ENDINTERFACE.

CLASS lcl_aggregate DEFINITION FRIENDS lif_iterator.
  PUBLIC SECTION.
    METHODS: create_iterator RETURNING VALUE(ro_iterator) TYPE REF TO lif_iterator,
             constructor.
  PRIVATE SECTION.
    DATA:
      mt_data TYPE STANDARD TABLE OF spfli.
ENDCLASS.

CLASS lcl_iterator DEFINITION.
  PUBLIC SECTION.
    INTERFACES: lif_iterator.
    ALIASES: first FOR lif_iterator~first,
             next  FOR lif_iterator~next,
             is_done FOR lif_iterator~is_done,
             current FOR lif_iterator~current.
    METHODS:
      constructor IMPORTING io_aggregate TYPE REF TO lcl_aggregate.
 PRIVATE SECTION.
  DATA:
    mv_position TYPE i,
    mv_lines    TYPE i,
    mo_aggregate TYPE REF TO lcl_aggregate.
ENDCLASS.

*&---------------------------------------------------------------------*
*&  Реализация
*&---------------------------------------------------------------------*

CLASS lcl_aggregate IMPLEMENTATION.
  METHOD constructor.
    SELECT * FROM spfli INTO CORRESPONDING FIELDS OF TABLE mt_data.
  ENDMETHOD.

  METHOD create_iterator.
    CREATE OBJECT ro_iterator TYPE lcl_iterator
      EXPORTING
        io_aggregate = me.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_iterator IMPLEMENTATION.
  METHOD constructor.
    mo_aggregate = io_aggregate.
    mv_lines = lines( mo_aggregate->mt_data ).
    mv_position = 0.
  ENDMETHOD.

  METHOD first.
    mv_position = 1.

    READ TABLE mo_aggregate->mt_data INDEX mv_position INTO rs_spfli.
  ENDMETHOD.

  METHOD next.
    mv_position = mv_position + 1.

    IF mv_position > mv_lines.
      mv_position = mv_position - 1.
      RETURN.
    ENDIF.

    READ TABLE mo_aggregate->mt_data INDEX mv_position INTO rs_spfli.
  ENDMETHOD.

  METHOD is_done.
    IF ( mv_position + 1 ) > mv_lines.
      rv_done = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD current.
    READ TABLE mo_aggregate->mt_data INDEX mv_position INTO rs_spfli.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*&  Работа с шаблоном
*&---------------------------------------------------------------------*

START-OF-SELECTION.
  DATA:
    lo_aggregate TYPE REF TO lcl_aggregate,
    lo_iterator  TYPE REF TO lif_iterator,
    ls_spfli     TYPE spfli.

  CREATE OBJECT lo_aggregate.
  lo_iterator = lo_aggregate->create_iterator( ).

  WHILE lo_iterator->is_done( ) <> abap_true.
    ls_spfli = lo_iterator->next( ).
    WRITE: / sy-index, ls_spfli-connid, ls_spfli-carrid.
  ENDWHILE.
