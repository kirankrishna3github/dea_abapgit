*&---------------------------------------------------------------------*
*& Report Z_021_ADAPTER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_021_ADAPTER.

CLASS lcl_target DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      request ABSTRACT.
ENDCLASS.

CLASS lcl_adaptee DEFINITION.
  PUBLIC SECTION.
    METHODS:
      special_request.
ENDCLASS.

CLASS lcl_adaptee IMPLEMENTATION.
  METHOD special_request.
    WRITE: / 'Adaptee call'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_adapter DEFINITION INHERITING FROM lcl_target.
  PUBLIC SECTION.
    METHODS:
      request REDEFINITION,
      constructor.
  PRIVATE SECTION.
    DATA:
          mo_adaptee TYPE REF TO lcl_adaptee.
ENDCLASS.

CLASS lcl_adapter IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    CREATE OBJECT mo_adaptee.
  ENDMETHOD.

  METHOD request.
    mo_adaptee->special_request( ).
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  DATA:
        lo_adapter TYPE REF TO lcl_adapter.

  CREATE OBJECT lo_adapter.
  lo_adapter->request( ).
