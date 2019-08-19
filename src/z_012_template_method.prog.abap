*&---------------------------------------------------------------------*
*& Report Z_012_TEMPLATE_METHOD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_012_template_method.

CLASS lcl_template_discount DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      calc_discount IMPORTING iv_product         TYPE string
                              iv_customer        TYPE string
                    RETURNING VALUE(rv_discount) TYPE i.
  PROTECTED SECTION.
    METHODS:
      calc_product_discount ABSTRACT
        IMPORTING iv_product         TYPE string
        RETURNING VALUE(rv_discount) TYPE i,
      calc_customer_discount ABSTRACT
        IMPORTING iv_customer        TYPE string
        RETURNING VALUE(rv_discount) TYPE i.
ENDCLASS.

CLASS lcl_workday_discount DEFINITION INHERITING FROM lcl_template_discount.
  PROTECTED SECTION.
    METHODS:
      calc_customer_discount REDEFINITION,
      calc_product_discount REDEFINITION.
ENDCLASS.

CLASS lcl_template_discount IMPLEMENTATION.
  METHOD calc_discount.
    DATA:
          lv_product_discount TYPE id,
          lv_customer_discount TYPE id.

    lv_product_discount = calc_product_discount( iv_product = iv_product ).
    lv_customer_discount = calc_customer_discount( iv_customer = iv_customer ).

    IF lv_product_discount > lv_customer_discount.
      rv_discount = lv_product_discount.
    ELSE.
      rv_discount = lv_customer_discount.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_workday_discount IMPLEMENTATION.
  METHOD calc_customer_discount.
    CASE iv_customer.
      WHEN 'John'.
        rv_discount = 10.
      WHEN OTHERS.
        rv_discount = 5.
    ENDCASE.
  ENDMETHOD.

  METHOD calc_product_discount.
    CASE iv_product.
      WHEN 'Milk'.
        rv_discount = 10.
      WHEN OTHERS.
        rv_discount = 5.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.



START-OF-SELECTION.
  DATA:
        lo_discounter TYPE REF TO lcl_template_discount,
        lv_discount   TYPE i.

  CREATE OBJECT lo_discounter TYPE lcl_workday_discount.
  lv_discount = lo_discounter->calc_discount(
      iv_product = 'Milk'
      iv_customer = 'John'
      ).

  WRITE lv_discount.

    lv_discount = lo_discounter->calc_discount(
      iv_product = 'Milk1'
      iv_customer = 'John'
      ).

  WRITE: / 'должна быть 10', lv_discount.

    lv_discount = lo_discounter->calc_discount(
      iv_product = 'Milk'
      iv_customer = 'John1'
      ).

  WRITE: / 'должна быть 10', lv_discount.

    lv_discount = lo_discounter->calc_discount(
      iv_product = 'Milk1'
      iv_customer = 'John1'
      ).

  WRITE: / 'должна быть 5', lv_discount.
