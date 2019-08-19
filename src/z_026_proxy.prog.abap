*&---------------------------------------------------------------------*
*& Report Z_026_PROXY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_026_proxy.

CLASS lcl_subject DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      get_data ABSTRACT RETURNING VALUE(rt_spfli) TYPE spfli_tab.
ENDCLASS.

CLASS lcl_real_subject DEFINITION INHERITING FROM lcl_subject.
  PUBLIC SECTION.
    METHODS:
      get_data REDEFINITION,
      constructor.
  PRIVATE SECTION.
    DATA:
          mt_data TYPE spfli_tab.
ENDCLASS.

CLASS lcl_real_subject IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    SELECT * FROM spfli INTO CORRESPONDING FIELDS OF TABLE mt_data.
  ENDMETHOD.

  METHOD get_data.
    rt_spfli = mt_data.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_proxy DEFINITION INHERITING FROM lcl_subject.
  PUBLIC SECTION.
    METHODS:
      get_data REDEFINITION.
  PRIVATE SECTION.
    DATA:
          mo_real_subject TYPE REF TO lcl_real_subject.
ENDCLASS.

CLASS lcl_proxy IMPLEMENTATION.
  METHOD get_data.
    " Инициализция будет происходить только при необходимости получить данные,
    " а не во время инициализации
    IF mo_real_subject IS NOT BOUND.
      CREATE OBJECT mo_real_subject.
    ENDIF.

    rt_spfli = mo_real_subject->get_data( ).
  ENDMETHOD.
ENDCLASS.



START-OF-SELECTION.
  DATA:
        lo_subject TYPE REF TO lcl_subject.

  CREATE OBJECT lo_subject TYPE lcl_proxy.
  DATA(lt_data) = lo_subject->get_data( ).
