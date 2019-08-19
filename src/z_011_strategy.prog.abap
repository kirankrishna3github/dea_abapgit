*&---------------------------------------------------------------------*
*& Report Z_011_STRATEGY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_011_STRATEGY.

PARAMETERS: p_a TYPE i,
            p_b TYPE i.

PARAMETERS:
        p_mul TYPE abap_bool RADIOBUTTON GROUP 1,
        p_sum TYPE abap_bool RADIOBUTTON GROUP 1,
        p_sub TYPE abap_bool RADIOBUTTON GROUP 1.

INTERFACE lif_strategy.
  METHODS:
    execute IMPORTING iv_a TYPE i
                      iv_b TYPE i
            RETURNING VALUE(rv_result) TYPE i.
ENDINTERFACE.

CLASS lcl_strategy_multiply DEFINITION.
  PUBLIC SECTION.
  INTERFACES: lif_strategy.
  ALIASES: execute FOR lif_strategy~execute.
ENDCLASS.

CLASS lcl_strategy_sum DEFINITION.
  PUBLIC SECTION.
  INTERFACES: lif_strategy.
  ALIASES: execute FOR lif_strategy~execute.
ENDCLASS.

CLASS lcl_strategy_sub DEFINITION.
  PUBLIC SECTION.
  INTERFACES: lif_strategy.
  ALIASES: execute FOR lif_strategy~execute.
ENDCLASS.



CLASS lcl_strategy_multiply IMPLEMENTATION.
  METHOD execute.
    rv_result = iv_a * iv_b.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_strategy_sum IMPLEMENTATION.
  METHOD execute.
    rv_result = iv_a + iv_b.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_strategy_sub IMPLEMENTATION.
  METHOD execute.
    rv_result = iv_a - iv_b.
  ENDMETHOD.
ENDCLASS.



START-OF-SELECTION.
  DATA:
        lif_strategy TYPE REF TO lif_strategy,
        lv_result    TYPE i.

  CASE abap_true.
    WHEN p_mul.
      CREATE OBJECT lif_strategy TYPE lcl_strategy_multiply.
    WHEN p_sum.
      CREATE OBJECT lif_strategy TYPE lcl_strategy_sum.
    WHEN p_sub.
      CREATE OBJECT lif_strategy TYPE lcl_strategy_sub.
  ENDCASE.

  lv_result = lif_strategy->execute(
                  iv_a = p_a
                  iv_b = p_b
                  ).

  WRITE lv_result.
