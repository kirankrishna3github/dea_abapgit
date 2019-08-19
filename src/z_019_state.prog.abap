*&---------------------------------------------------------------------*
*& Report Z_019_STATE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_019_STATE.

CLASS lcl_water DEFINITION DEFERRED.

INTERFACE lif_water_state.
  CONSTANTS:
    gc_state_solid  TYPE i VALUE 1,
    gc_state_liquid TYPE i VALUE 2,
    gc_state_gaz    TYPE i VALUE 3.

  METHODS:
    heat  IMPORTING io_water TYPE REF TO lcl_water OPTIONAL,
    frost IMPORTING io_water TYPE REF TO lcl_water OPTIONAL.
ENDINTERFACE.

CLASS lcl_water DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_water_state.
    ALIASES:
      heat FOR lif_water_state~heat,
      frost FOR lif_water_state~frost.

    METHODS:
      constructor IMPORTING io_state TYPE REF TO lif_water_state,
      set_state   IMPORTING io_state TYPE REF TO lif_water_state.
  PRIVATE SECTION.
    DATA:
          mo_state TYPE REF TO lif_water_state.
ENDCLASS.

CLASS lcl_water IMPLEMENTATION.
  METHOD constructor.
    set_state( io_state ).
  ENDMETHOD.

  METHOD heat.
    mo_state->heat( me ).
  ENDMETHOD.

  METHOD frost.
    mo_state->frost( me ).
  ENDMETHOD.

  METHOD set_state.
    mo_state = io_state.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_liquid_water_state DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_water_state.
    ALIASES:
      heat  FOR lif_water_state~heat,
      frost FOR lif_water_state~frost.
ENDCLASS.

CLASS lcl_solid_water_state DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_water_state.
    ALIASES:
      heat  FOR lif_water_state~heat,
      frost FOR lif_water_state~frost.
ENDCLASS.

CLASS lcl_gaz_water_state DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_water_state.
    ALIASES:
      heat  FOR lif_water_state~heat,
      frost FOR lif_water_state~frost.
ENDCLASS.

CLASS lcl_liquid_water_state IMPLEMENTATION.
  METHOD heat.
    WRITE: / 'Превращаем воду в пар'.
    io_water->set_state( io_state = CAST #( NEW lcl_gaz_water_state( ) ) ).
  ENDMETHOD.

  METHOD frost.
    WRITE: / 'Превращаем воду в лед'.
    io_water->set_state( io_state = CAST #( NEW lcl_solid_water_state( ) ) ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_solid_water_state IMPLEMENTATION.
  METHOD heat.
    WRITE: / 'Превращаем лед в жидкость'.
    io_water->set_state( io_state = CAST #( NEW lcl_liquid_water_state( ) ) ).
  ENDMETHOD.

  METHOD frost.
    WRITE: / 'Замораживаем лед еще раз'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_gaz_water_state IMPLEMENTATION.
  METHOD heat.
    WRITE: / 'Повышаем температуру пара'.
  ENDMETHOD.

  METHOD frost.
    WRITE: / 'Превращаем пар в воду'.
    io_water->set_state( io_state = CAST #( NEW lcl_liquid_water_state( ) ) ).
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*&  Работа с классами шаблона
*&---------------------------------------------------------------------*

START-OF-SELECTION.
  DATA(lo_water) = NEW lcl_water( NEW lcl_liquid_water_state( ) ).

  lo_water->heat( ).
  lo_water->heat( ).
  lo_water->heat( ).
  lo_water->frost( ).
  lo_water->frost( ).
  lo_water->frost( ).
  lo_water->frost( ).
  lo_water->frost( ).
  lo_water->heat( ).
