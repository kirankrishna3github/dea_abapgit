*&---------------------------------------------------------------------*
*& Report Z_008_BUILDER_V1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_008_BUILDER_V1.

CLASS lcl_product DEFINITION.
  PUBLIC SECTION.
    DATA:
          mv_header TYPE string,
          mv_footer TYPE string,
          mv_text   TYPE string.
  METHODS: write.
ENDCLASS.

CLASS lcl_product IMPLEMENTATION.
  METHOD write.
    WRITE: / 'HDR:', mv_header, 'FTR:', mv_footer, 'TXT:', mv_text. "|'HDR:' {mv_header} |
  ENDMETHOD.
ENDCLASS.

CLASS lcl_builder DEFINITION.
  PUBLIC SECTION.
    METHODS:
      init_product  RETURNING VALUE(ro_builder) TYPE REF TO lcl_builder,
      set_header    IMPORTING iv_header         TYPE string RETURNING VALUE(ro_builder) TYPE REF TO lcl_builder,
      set_footer    IMPORTING iv_footer         TYPE string RETURNING VALUE(ro_builder) TYPE REF TO lcl_builder,
      set_text      IMPORTING iv_text           TYPE string RETURNING VALUE(ro_builder) TYPE REF TO lcl_builder,
      get_product   RETURNING VALUE(ro_product) TYPE REF TO lcl_product.
  PRIVATE SECTION.
    DATA mo_product TYPE REF TO lcl_product.
ENDCLASS.

CLASS lcl_builder IMPLEMENTATION.
  METHOD init_product.
    CREATE OBJECT mo_product.
    ro_builder = me.
  ENDMETHOD.

  METHOD set_header.
    IF mo_product IS NOT BOUND.
      init_product( ).
    ENDIF.

    mo_product->mv_header = iv_header.
    ro_builder = me.
  ENDMETHOD.

  METHOD set_footer.
    IF mo_product IS NOT BOUND.
      init_product( ).
    ENDIF.

    mo_product->mv_footer = iv_footer.
    ro_builder = me.
  ENDMETHOD.

  METHOD set_text.
    IF mo_product IS NOT BOUND.
      init_product( ).
    ENDIF.

    mo_product->mv_text = iv_text.
    ro_builder = me.
  ENDMETHOD.

  METHOD get_product.
    ro_product = mo_product.
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.
  DATA:
        lo_product TYPE REF TO lcl_product,
        lo_builder TYPE REF TO lcl_builder.

  CREATE OBJECT lo_builder.
  lo_product = lo_builder->set_footer( 'Footer 1' )->set_header( 'Headrer 1' )->set_text( 'Text 1' )->get_product( ).
  lo_product->write( ).
  lo_product = lo_builder->init_product( )->set_footer( 'Footer 2' )->set_header( 'Headrer 2' )->set_text( 'Text 2' )->get_product( ).
  lo_product->write( ).
