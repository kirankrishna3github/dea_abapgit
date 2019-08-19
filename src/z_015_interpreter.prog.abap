*&---------------------------------------------------------------------*
*& Report Z_015_INTERPRETER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_015_interpreter.

CLASS lcl_context DEFINITION.
  PUBLIC SECTION.
    DATA:
          mv_output TYPE string.
ENDCLASS.

INTERFACE lif_expression.
  METHODS:
    interpret IMPORTING io_context TYPE REF TO lcl_context.
ENDINTERFACE.

*&---------------------------------------------------------------------*
*&  Соусы
*&---------------------------------------------------------------------*

CLASS lcl_garlicsauce DEFINITION.
  PUBLIC SECTION.
    INTERFACES: lif_expression.
ENDCLASS.

CLASS lcl_garlicsauce IMPLEMENTATION.
  METHOD lif_expression~interpret.
    io_context->mv_output = io_context->mv_output && 'garlic sauce'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_cheesesauce DEFINITION.
  PUBLIC SECTION.
    INTERFACES: lif_expression.
ENDCLASS.

CLASS lcl_cheesesauce IMPLEMENTATION.
  METHOD lif_expression~interpret.
    io_context->mv_output = io_context->mv_output && 'cheese sauce'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_sauce_list DEFINITION.
  PUBLIC SECTION.
    INTERFACES: lif_expression.
    METHODS:
      add_sauce IMPORTING io_sauce TYPE REF TO lif_expression.
  PRIVATE SECTION.
    DATA:
          mt_sauces TYPE STANDARD TABLE OF REF TO lif_expression.
ENDCLASS.

CLASS lcl_sauce_list IMPLEMENTATION.
  METHOD add_sauce.
    APPEND io_sauce TO mt_sauces.
  ENDMETHOD.

  METHOD lif_expression~interpret.
    DATA:
          lo_sauce TYPE REF TO lif_expression.

    io_context->mv_output = io_context->mv_output && '<--sauce list: '.
    LOOP AT mt_sauces INTO lo_sauce.
      lo_sauce->interpret( io_context ).
      io_context->mv_output = io_context->mv_output && '; '.
    ENDLOOP.
    io_context->mv_output = io_context->mv_output && '-->'.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*&  Ингридиенты
*&---------------------------------------------------------------------*

CLASS lcl_tomatoingredient DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_expression.
ENDCLASS.

CLASS lcl_tomatoingredient IMPLEMENTATION.
  METHOD lif_expression~interpret.
    io_context->mv_output = io_context->mv_output && 'tomato'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_chikeningredient DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_expression.
ENDCLASS.

CLASS lcl_chikeningredient IMPLEMENTATION.
  METHOD lif_expression~interpret.
    io_context->mv_output = io_context->mv_output && 'chiken'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_ingredientlist DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_expression.
    METHODS:
      add_ingredient IMPORTING io_ingredient TYPE REF TO lif_expression.
  PRIVATE SECTION.
    DATA:
          mt_ingredients TYPE STANDARD TABLE OF REF TO lif_expression.
ENDCLASS.

CLASS lcl_ingredientlist IMPLEMENTATION.
  METHOD add_ingredient.
    APPEND io_ingredient TO mt_ingredients.
  ENDMETHOD.

  METHOD lif_expression~interpret.
    DATA:
          lo_ingredient TYPE REF TO lif_expression.

    io_context->mv_output = io_context->mv_output && '<--ingredient list: '.
    LOOP AT mt_ingredients INTO lo_ingredient.
      lo_ingredient->interpret( io_context ).
      io_context->mv_output = io_context->mv_output && ' '.
    ENDLOOP.
    io_context->mv_output = io_context->mv_output && '-->'.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*&  Хлеб
*&---------------------------------------------------------------------*

CLASS lcl_whitebread DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_expression.
ENDCLASS.

CLASS lcl_whitebread IMPLEMENTATION.
  METHOD lif_expression~interpret.
    io_context->mv_output = io_context->mv_output && '<--White bread-->'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_wheatbread DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_expression.
ENDCLASS.

CLASS lcl_wheatbread IMPLEMENTATION.
  METHOD lif_expression~interpret.
    io_context->mv_output = io_context->mv_output && '<--Wheat bread-->'.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*&  Саб
*&---------------------------------------------------------------------*

CLASS lcl_sub DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_expression.
    METHODS:
      constructor IMPORTING
                        io_saucelist  TYPE REF TO lcl_sauce_list
                        io_bread      TYPE REF TO lif_expression
                        io_ingredientlist TYPE REF TO lcl_ingredientlist.
  PRIVATE SECTION.
    DATA:
          mo_saucelist  TYPE REF TO lcl_sauce_list,
          mo_bread      TYPE REF TO lif_expression,
          mo_ingredientlist TYPE REF TO lcl_ingredientlist.
ENDCLASS.

CLASS lcl_sub IMPLEMENTATION.
  METHOD constructor.
    mo_saucelist = io_saucelist.
    mo_bread = io_bread.
    mo_ingredientlist = io_ingredientlist.
  ENDMETHOD.

  METHOD lif_expression~interpret.
    mo_bread->interpret( io_context ).
    mo_saucelist->lif_expression~interpret( io_context ).
    mo_ingredientlist->lif_expression~interpret( io_context ).
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*&  Работа с шаблоном
*&---------------------------------------------------------------------*

START-OF-SELECTION.
  DATA(lo_saucelist) = NEW lcl_sauce_list( ).
  lo_saucelist->add_sauce( io_sauce = NEW lcl_cheesesauce( ) ).
  lo_saucelist->add_sauce( io_sauce = NEW lcl_garlicsauce( ) ).

  DATA(lo_ingredient) = NEW lcl_ingredientlist( ).
  lo_ingredient->add_ingredient( io_ingredient = NEW lcl_chikeningredient( ) ).

  DATA(lo_sub) = NEW lcl_sub( io_bread = NEW lcl_whitebread( )
                              io_ingredientlist = lo_ingredient
                              io_saucelist = lo_saucelist ).

  DATA(lo_context) = NEW lcl_context( ).
  lo_sub->lif_expression~interpret( lo_context ).
  WRITE lo_context->mv_output.
