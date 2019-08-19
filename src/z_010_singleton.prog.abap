*&---------------------------------------------------------------------*
*& Report Z_010_SINGLETON
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_010_SINGLETON.

INTERFACE lif_singleton.
  METHODS:
    do_something.
ENDINTERFACE.

CLASS lcl_singleton DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    INTERFACES: lif_singleton.
    ALIASES: do_something FOR lif_singleton~do_something.
    CLASS-DATA:
      go_instance TYPE REF TO lif_singleton.
    CLASS-METHODS:
      get_instance RETURNING VALUE(ro_singleton) TYPE REF TO lif_singleton.
ENDCLASS.

CLASS lcl_singleton IMPLEMENTATION.
  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      CREATE OBJECT go_instance TYPE lcl_singleton.
    ENDIF.

    ro_singleton = go_instance.
  ENDMETHOD.

  METHOD do_something.
    WRITE 'Something'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_singleton_for_testing DEFINITION.
  PUBLIC SECTION.
    INTERFACES: lif_singleton.
    ALIASES: do_something FOR lif_singleton~do_something.
ENDCLASS.

CLASS lcl_singleton_for_testing IMPLEMENTATION.
  METHOD do_something.
    WRITE 'Something for test'.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  DATA: lo_singleton TYPE REF TO lif_singleton.
  DATA: lo_singleton_for_testing TYPE REF TO lcl_singleton_for_testing.

*  CREATE OBJECT lo_singleton.
  lcl_singleton=>go_instance = lo_singleton. "for_testing

  lo_singleton ?= lcl_singleton=>get_instance( ).
  lo_singleton->do_something( ).
