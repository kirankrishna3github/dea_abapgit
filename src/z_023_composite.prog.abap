*&---------------------------------------------------------------------*
*& Report Z_023_COMPOSITE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_023_COMPOSITE.

CLASS lcl_component DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iv_name TYPE string,
      operation ABSTRACT,
      add ABSTRACT IMPORTING io_component TYPE REF TO lcl_component,
      remove ABSTRACT IMPORTING io_component TYPE REF TO lcl_component,
      get_child ABSTRACT IMPORTING iv_index TYPE i
                         RETURNING VALUE(ro_component) TYPE REF TO lcl_component.
  PROTECTED SECTION.
    DATA:
          mv_name TYPE string.
ENDCLASS.

CLASS lcl_component IMPLEMENTATION.
  METHOD constructor.
    mv_name = iv_name.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_leaf DEFINITION INHERITING FROM lcl_component.
  PUBLIC SECTION.
    METHODS:
      operation REDEFINITION,
      add REDEFINITION,
      remove REDEFINITION,
      get_child REDEFINITION.
ENDCLASS.

CLASS lcl_leaf IMPLEMENTATION.
  METHOD operation.
    WRITE: / mv_name, ' lcl_leaf'.
  ENDMETHOD.

  METHOD add.
  ENDMETHOD.

  METHOD remove.
  ENDMETHOD.

  METHOD get_child.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_composite DEFINITION INHERITING FROM lcl_component.
  PUBLIC SECTION.
    METHODS:
      operation REDEFINITION,
      add REDEFINITION,
      remove REDEFINITION,
      get_child REDEFINITION.
  PRIVATE SECTION.
    DATA:
          mt_childrens TYPE STANDARD TABLE OF REF TO lcl_component.
ENDCLASS.

CLASS lcl_composite IMPLEMENTATION.
  METHOD operation.
    WRITE: / mv_name.

    LOOP AT mt_childrens INTO DATA(lo_child).
      lo_child->operation( ).
    ENDLOOP.
  ENDMETHOD.

  METHOD add.
    APPEND io_component TO mt_childrens.
  ENDMETHOD.

  METHOD remove.
    DELETE mt_childrens WHERE TABLE_LINE = io_component.
  ENDMETHOD.

  METHOD get_child.
    READ TABLE mt_childrens INDEX iv_index INTO ro_component.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  DATA(lo_root) = NEW lcl_composite( iv_name = 'ROOT' ).

  DATA(lo_branch1) = NEW lcl_composite( iv_name = 'BR1' ).
  DATA(lo_branch2) = NEW lcl_composite( iv_name = 'BR2' ).

  DATA(lo_leaf1) = NEW lcl_composite( iv_name = 'LF1' ).
  DATA(lo_leaf2) = NEW lcl_composite( iv_name = 'LF2' ).

  lo_branch1->add( lo_leaf1 ).
  lo_branch1->add( lo_leaf2 ).

  lo_root->add( lo_branch1 ).
  lo_root->add( lo_branch2 ).

  lo_root->operation( ).
