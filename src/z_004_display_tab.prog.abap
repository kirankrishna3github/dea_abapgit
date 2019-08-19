*&---------------------------------------------------------------------*
*& Report Z_004_DISPLAY_TAB
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_004_DISPLAY_TAB.

*DATA table1 TYPE table.

*START-OF-SELECTION.
*
*  PARAMETERS p_tab TYPE c LENGTH 8.
*
*  SELECT *
*    INTO TABLE @data(table1)
*    FROM spfli.
*
*
**  DATA zmytable TYPE ( p_tab ).
*
*  DATA: BEGIN OF wa_table.
*  INCLUDE TYPE table1 AS zmytable.
*  DATA: my_field TYPE coep-wogbtr
*      , END OF   wa_table.
*
*  DATA: table TYPE TABLE OF wa_table.
*
*  LOOP AT table1 ASSIGNING FIELD-SYMBOL(<stab>).
**    wa_table-mandt = <stab>-mandt.
*    APPEND <stab> TO wa_table.
*  ENDLOOP.
*
*
*  BREAK-POINT.


*
*
*
*  TYPES:
*  BEGIN OF abap_compdescr,
*    length    TYPE i,
*    decimals  TYPE i,
*    type_kind TYPE char1,
*    name      TYPE char30,
*  END OF abap_compdescr.
*
*FIELD-SYMBOLS: <l_struct> TYPE abap_compdescr,
*                         <t_tab>  TYPE ANY TABLE.
*
*DATA: l_line  TYPE REF TO cl_abap_structdescr,
*          it_struct TYPE TABLE OF abap_compdescr,
*          wa_fcat TYPE lvc_s_fcat,
*          it_fcat TYPE lvc_t_fcat,
*          table TYPE REF TO data.
*
*l_line ?= cl_abap_typedescr=>describe_by_data( p_data =  ).
*
*it_struct[] = l_line->components[].
*
*loop at it_struct assigning <l_struct>.
*
**  //тут заполняешь it_fcat данными из <l_struct>
*
*endloop.
*
**//тут добавляешь в it_fcat свое поле
*
*  CALL METHOD cl_alv_table_create=>create_dynamic_table
*    EXPORTING
*      it_fieldcatalog = it_fcat
*    IMPORTING
*      ep_table        = table.
*
*  ASSIGN table->* TO <t_tab>.

"Описание параметров СЭ
parameters
  : p_name     type fieldname
  , p_type     type c
  , p_len      type i
  , p_tbnam    type string
  .
"Описание данных
data "Структура таблицы в которой будут храниться
     "введенные пользователем описания полей, динамической табл.
  : begin   of   gs_task
  ,   name  like p_name " имя поля
  ,   type  like p_type " тип поля
  ,   len   like p_len  " длина поля
  , end     of   gs_task
  , gt_task like standard table of gs_task
            with key name
  , gt_fld  type standard table of fieldname " список полей для выборки
  , gr      type ref to data
  .
field-symbols
  : <table> type standard table
  .
at selection-screen.
  gs_task-name = p_name .
  gs_task-type = p_type .
  gs_task-len  = p_len  .
  "Заполняем таблицу данными c СЭ
  append gs_task to gt_task.

start-of-selection.
  perform table_creation. " создание таблицы
  perform table_reading.  " заполнение и вывод на экран
*&---------------------------------------------------------------------*
*&      Form  table_creation
*&---------------------------------------------------------------------*
form table_creation.
  data
    : lo_struct  type ref to cl_abap_structdescr
    , lo_table   type ref to cl_abap_tabledescr
    , ls_comp    type abap_componentdescr
    , lt_comp    type abap_component_tab
    .
  sort gt_task.
  delete adjacent duplicates from gt_task.
  loop at gt_task into gs_task.
    ls_comp-name = gs_task-name. " имя поля
    case gs_task-type.
    " используем методы (get_i, get_d, get_c, get_n) класса cl_abap_elemdescr
    " которые возвращают тип объекта для элементарного типа, так же
    " используем значение gs_task-len внутри метода для указания длины типа данных

      when 'I'. " Числовое поле
        ls_comp-type = cl_abap_elemdescr=>get_i( ).
      when 'D'. " Поле типа ДАТА
        ls_comp-type = cl_abap_elemdescr=>get_d( ).
      when 'C'. " Текстовое поле с переменной длиной
        ls_comp-type = cl_abap_elemdescr=>get_c( gs_task-len ).
      when 'N'. " Текстовое поле(для хранения чисел) с переменной длиной
        ls_comp-type = cl_abap_elemdescr=>get_n( gs_task-len ).
    endcase.
    append ls_comp to lt_comp.
    append gs_task-name to gt_fld.
  endloop.
  lo_struct = cl_abap_structdescr=>create( lt_comp ).  " создаем объект структуру
  lo_table  = cl_abap_tabledescr=>create( lo_struct ). " создаем объект таблицу
  create data gr  type handle lo_table. " создаем обект-данных полученного типа
  assign gr->* to <table>. "создаем таблицу
endform.                    "table_creation
*&---------------------------------------------------------------------*
*&      Form  table_reading
*&---------------------------------------------------------------------*
form table_reading.
  " Выборка

  DATA(field) = 'CITYTO'.
  APPEND field TO gt_fld.

  select (gt_fld)  " поля указанные пользователем на СЭ
    from (p_tbnam) " таблица указанная пользователем на СЭ
         into corresponding fields of table <table>.

  field-symbols
    : <ls_wa> type any
    , <comp> type any
    .
" Вывод выбранных записей
  loop at <table> assigning <ls_wa>.
    new-line.
    do.
      assign component sy-index of structure <ls_wa> to <comp>.
      if sy-subrc ne 0.
        exit.
      endif.
      write <comp>.
    enddo.
  endloop.
endform.                    "table_reading
