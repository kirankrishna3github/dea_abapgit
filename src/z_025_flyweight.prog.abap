*&---------------------------------------------------------------------*
*& Report Z_025_FLYWEIGHT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_025_flyweight.

CLASS lcl_character DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      display,
      constructor IMPORTING iv_character TYPE c.
  PROTECTED SECTION.
    DATA:
      mv_char   TYPE c,
      mv_width  TYPE i,
      mv_height TYPE i.
ENDCLASS.

CLASS lcl_character IMPLEMENTATION.
  METHOD display.
    WRITE: / 'Char: ', mv_char, 'Width: ', mv_width, 'Height: ', mv_height.
  ENDMETHOD.

  METHOD constructor.
    mv_char = iv_character.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_character_a DEFINITION INHERITING FROM lcl_character.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iv_character TYPE c.
ENDCLASS.

CLASS lcl_character_a IMPLEMENTATION.
  METHOD constructor.
    super->constructor( iv_character = iv_character ).

    mv_width = 100.
    mv_height = 100.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_character_b DEFINITION INHERITING FROM lcl_character.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iv_character TYPE c.
ENDCLASS.

CLASS lcl_character_b IMPLEMENTATION.
  METHOD constructor.
    super->constructor( iv_character = iv_character ).

    mv_width = 200.
    mv_height = 200.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_character_c DEFINITION INHERITING FROM lcl_character.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iv_character TYPE c.
ENDCLASS.

CLASS lcl_character_c IMPLEMENTATION.
  METHOD constructor.
    super->constructor( iv_character = iv_character ).

    mv_width = 300.
    mv_height = 300.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_character_factory DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      get_character IMPORTING iv_char             TYPE c
                    RETURNING VALUE(ro_character) TYPE REF TO lcl_character.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_char,
        char TYPE c LENGTH 1,
        ref  TYPE REF TO lcl_character,
      END OF ty_char.
    CLASS-DATA:
      lt_characters TYPE STANDARD TABLE OF ty_char.
ENDCLASS.

CLASS lcl_character_factory IMPLEMENTATION.
  METHOD get_character.
    TRY.
        ro_character = lt_characters[ char = iv_char ]-ref.

      CATCH cx_sy_itab_line_not_found.
        APPEND INITIAL LINE TO lt_characters ASSIGNING FIELD-SYMBOL(<ls_line>).

        <ls_line>-char = iv_char.

        CASE <ls_line>-char.
          WHEN 'A'.
            <ls_line>-ref = NEW lcl_character_a( iv_char ).
          WHEN 'B'.
            <ls_line>-ref = NEW lcl_character_b( iv_char ).
          WHEN 'C'.
            <ls_line>-ref = NEW lcl_character_c( iv_char ).
        ENDCASE.

        ro_character = <ls_line>-ref.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  DATA:
    lv_message   TYPE string VALUE 'ABBCCBBABBCABBCCC',
    lo_character TYPE REF TO lcl_character.

  DO strlen( lv_message ) - 1 TIMES.
    lo_character = lcl_character_factory=>get_character( iv_char = substring( val = lv_message off = sy-index len = 1 ) ).
    lo_character->display( ).
  ENDDO.
