*&---------------------------------------------------------------------*
*& Report Z_006_ABS_FACTORY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_006_abs_factory.

CLASS abs_data DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS: read_data ABSTRACT.
ENDCLASS.

CLASS data_from_file DEFINITION INHERITING FROM abs_data.
  PUBLIC SECTION.
    METHODS: read_data REDEFINITION.
ENDCLASS.

CLASS data_from_file IMPLEMENTATION.
  METHOD: read_data.
    WRITE: / 'Чтение из файла'.
  ENDMETHOD.
ENDCLASS.

CLASS data_from_db DEFINITION INHERITING FROM abs_data.
  PUBLIC SECTION.
    METHODS: read_data REDEFINITION.
ENDCLASS.

CLASS data_from_db IMPLEMENTATION.
  METHOD read_data.
    WRITE: / 'Чтение из БД'.
  ENDMETHOD.
ENDCLASS.

CLASS abs_print DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS: write_data ABSTRACT.
ENDCLASS.

CLASS print_alv DEFINITION INHERITING FROM abs_print.
  PUBLIC SECTION.
    METHODS: write_data REDEFINITION.
ENDCLASS.

CLASS print_alv IMPLEMENTATION.
  METHOD write_data.
    WRITE: / 'Запись данных в ALV'.
  ENDMETHOD.
ENDCLASS.

CLASS print_simple DEFINITION INHERITING FROM abs_print.
  PUBLIC SECTION.
    METHODS: write_data REDEFINITION.
ENDCLASS.

CLASS print_simple IMPLEMENTATION.
  METHOD write_data.
    WRITE: / 'Простой вывод данных'.
  ENDMETHOD.
ENDCLASS.



CLASS report DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      get_data ABSTRACT,
      write_data ABSTRACT.
ENDCLASS.

CLASS simplereport DEFINITION INHERITING FROM report.
  PUBLIC SECTION.
    METHODS:
      get_data REDEFINITION,
      write_data REDEFINITION.
ENDCLASS.

CLASS simplereport IMPLEMENTATION.
  METHOD get_data.
    DATA lo_data TYPE REF TO data_from_file.
    CREATE OBJECT lo_data.
    lo_data->read_data( ).
  ENDMETHOD.

  METHOD write_data.
    DATA lo_print TYPE REF TO print_simple.
    CREATE OBJECT lo_print.
    lo_print->write_data( ).
  ENDMETHOD.

ENDCLASS.

CLASS complexreport DEFINITION INHERITING FROM report.
  PUBLIC SECTION.
    METHODS:
      get_data REDEFINITION,
      write_data REDEFINITION.
ENDCLASS.

CLASS complexreport IMPLEMENTATION.
  METHOD get_data.
    DATA lo_data TYPE REF TO data_from_db.
    CREATE OBJECT lo_data.
    lo_data->read_data( ).
  ENDMETHOD.

  METHOD write_data.
    DATA lo_print TYPE REF TO print_alv.
    CREATE OBJECT lo_print.
    lo_print->write_data( ).
  ENDMETHOD.

ENDCLASS.


CLASS lcl_main_app DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: run.
ENDCLASS.

CLASS lcl_main_app IMPLEMENTATION.
  METHOD run.
    DATA lo_report TYPE REF TO  report.
    CREATE OBJECT lo_report TYPE simplereport.
    lo_report->get_data( ).
    lo_report->write_data( ).

    CREATE OBJECT lo_report TYPE complexreport.
    lo_report->get_data( ).
    lo_report->write_data( ).
  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.
  lcl_main_app=>run( ).
