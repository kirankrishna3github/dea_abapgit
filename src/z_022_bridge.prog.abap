*&---------------------------------------------------------------------*
*& Report Z_022_BRIDGE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_022_bridge.

CLASS lcl_printer DEFINITION DEFERRED.

CLASS lcl_report DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      print_report,
      constructor IMPORTING io_printer TYPE REF TO lcl_printer.
  PROTECTED SECTION.
    DATA:
      mv_data    TYPE string,
      mo_printer TYPE REF TO lcl_printer.
    METHODS:
      get_data ABSTRACT,
      write_data ABSTRACT.
ENDCLASS.

CLASS lcl_report IMPLEMENTATION.
  METHOD constructor.
    mo_printer = io_printer.
  ENDMETHOD.

  METHOD print_report.
    me->get_data( ).
    me->write_data( ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_report_one DEFINITION INHERITING FROM lcl_report.
  PROTECTED SECTION.
    METHODS:
      get_data REDEFINITION,
      write_data REDEFINITION.
ENDCLASS.

CLASS lcl_report_two DEFINITION INHERITING FROM lcl_report.
  PROTECTED SECTION.
    METHODS:
      get_data REDEFINITION,
      write_data REDEFINITION.
ENDCLASS.

CLASS lcl_printer DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      write_data ABSTRACT IMPORTING iv_data TYPE string.
ENDCLASS.

CLASS lcl_report_one IMPLEMENTATION.
  METHOD get_data.
    mv_data = 'REP1 DATA'.
  ENDMETHOD.

  METHOD write_data.
    mo_printer->write_data( mv_data ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_report_two IMPLEMENTATION.
  METHOD get_data.
    mv_data = 'REP2 DATA'.
  ENDMETHOD.

  METHOD write_data.
    mo_printer->write_data( mv_data ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_printer_pdf DEFINITION INHERITING FROM lcl_printer.
  PUBLIC SECTION.
    METHODS:
      write_data REDEFINITION.
ENDCLASS.

CLASS lcl_printer_pdf IMPLEMENTATION.
  METHOD write_data.
    WRITE: / 'PDF: ', iv_data.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_printer_doc DEFINITION INHERITING FROM lcl_printer.
  PUBLIC SECTION.
    METHODS:
      write_data REDEFINITION.
ENDCLASS.

CLASS lcl_printer_doc IMPLEMENTATION.
  METHOD write_data.
    WRITE: / 'DOC: ', iv_data.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_printer_xml DEFINITION INHERITING FROM lcl_printer.
  PUBLIC SECTION.
    METHODS:
      write_data REDEFINITION.
ENDCLASS.

CLASS lcl_printer_xml IMPLEMENTATION.
  METHOD write_data.
    WRITE: / 'XML: ', iv_data.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  DATA(lo_rep_one) = NEW lcl_report_one( io_printer = NEW lcl_printer_pdf( ) ).
  DATA(lo_rep_two) = NEW lcl_report_two( io_printer = NEW lcl_printer_doc( ) ).

  lo_rep_one->print_report( ).
  lo_rep_two->print_report( ).
