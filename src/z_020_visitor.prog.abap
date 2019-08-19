*&---------------------------------------------------------------------*
*& Report Z_020_VISITOR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_020_visitor.

CLASS lcl_element DEFINITION DEFERRED.

CLASS lcl_visitor DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      visit ABSTRACT IMPORTING io_element TYPE REF TO lcl_element.
ENDCLASS.

CLASS lcl_element DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      accept IMPORTING io_visitor TYPE REF TO lcl_visitor.
ENDCLASS.

CLASS lcl_element IMPLEMENTATION.
  METHOD accept.
    io_visitor->visit( me ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_element_one DEFINITION INHERITING FROM lcl_element.
  PUBLIC SECTION.
    METHODS:
      operation_a.
ENDCLASS.

CLASS lcl_element_two DEFINITION INHERITING FROM lcl_element.
  PUBLIC SECTION.
    METHODS:
      operation_b.
ENDCLASS.

CLASS lcl_element_one IMPLEMENTATION.
  METHOD operation_a.
    WRITE: / 'Operation element one'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_element_two IMPLEMENTATION.
  METHOD operation_b.
    WRITE: / 'Operation element two'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_visitor_one DEFINITION INHERITING FROM lcl_visitor.
  PUBLIC SECTION.
    METHODS:
      visit REDEFINITION.
ENDCLASS.

CLASS lcl_visitor_one IMPLEMENTATION.
  METHOD visit.
    DATA:
          lo_element_one TYPE REF TO lcl_element_one.

    TRY.
        lo_element_one ?= io_element.
        lo_element_one->operation_a( ).
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_visitor_two DEFINITION INHERITING FROM lcl_visitor.
  PUBLIC SECTION.
    METHODS:
      visit REDEFINITION.
ENDCLASS.

CLASS lcl_visitor_two IMPLEMENTATION.
  METHOD visit.
    DATA:
          lo_element_two TYPE REF TO lcl_element_two.

    TRY.
        lo_element_two ?= io_element.
        lo_element_two->operation_b( ).
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_structure DEFINITION INHERITING FROM lcl_element.
  PUBLIC SECTION.
    METHODS:
      add_element IMPORTING io_element TYPE REF TO lcl_element,
      accept REDEFINITION.
  PRIVATE SECTION.
    DATA:
          mt_elements TYPE STANDARD TABLE OF REF TO lcl_element.
ENDCLASS.

CLASS lcl_structure IMPLEMENTATION.
  METHOD add_element.
    APPEND io_element TO mt_elements.
  ENDMETHOD.

  METHOD accept.
    DATA:
          lo_element TYPE REF TO lcl_element.

    LOOP AT mt_elements INTO lo_element.
      io_visitor->visit( lo_element ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  DATA:
    lo_structure TYPE REF TO lcl_structure,
    lo_el_one    TYPE REF TO lcl_element_one,
    lo_el_two    TYPE REF TO lcl_element_two,
    lo_vis_one   TYPE REF TO lcl_visitor_one,
    lo_vis_two   TYPE REF TO lcl_visitor_two.

  CREATE OBJECT lo_structure.
  CREATE OBJECT lo_el_one.
  CREATE OBJECT lo_el_two.
  CREATE OBJECT lo_vis_one.
  CREATE OBJECT lo_vis_two.

  lo_structure->add_element( lo_el_one ).
  lo_structure->add_element( lo_el_two ).

  lo_structure->accept( lo_vis_two ).
  lo_structure->accept( lo_vis_one ).
