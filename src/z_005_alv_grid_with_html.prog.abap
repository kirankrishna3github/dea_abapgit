*&---------------------------------------------------------------------*
*& Report Z_005_ALV_GRID_WITH_HTML
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_005_alv_grid_with_html.

*DATA: gt_alv TYPE TABLE OF sflight. " Таблица для ALV
DATA: go_alv TYPE REF TO cl_gui_alv_grid. " объект ALV
DATA: go_docking TYPE REF TO cl_gui_docking_container. " Общий контейнер
DATA: go_splitter TYPE REF TO cl_gui_splitter_container. " Разделитель
DATA: go_container_1 TYPE REF TO cl_gui_container. " верхний контейнер
DATA: go_container_2 TYPE REF TO cl_gui_container. " Нижний контейнер
DATA: go_html_cntrl TYPE REF TO cl_gui_html_viewer. " HTML контроллер

TYPES : BEGIN OF ty.
          INCLUDE STRUCTURE sflight.
* For cell editing and displaying cell as push button
          TYPES : cellstyles TYPE lvc_t_styl,
* For cell coloring
          cellcolor  TYPE lvc_t_scol,
        END OF ty.

DATA : gt_alv      TYPE STANDARD TABLE OF ty, "Output Internal table
       i_fieldcat  TYPE STANDARD TABLE OF lvc_s_fcat, "Field catalog
       wa          TYPE ty,
       w_variant   TYPE disvariant,
       w_layout    TYPE lvc_s_layo, "Layout structure
       w_cellcolor TYPE lvc_s_scol, "For cell color
       w_style     TYPE lvc_s_styl, "cell editing and
       "displaying cell as push button
       o_docking   TYPE REF TO cl_gui_docking_container, "Docking Container         go_docking
       o_grid      TYPE REF TO cl_gui_alv_grid. "Grid                                  gp_alv


*----------------------------------------------------------------------*
*       CLASS lcl_alv_handler DEFINITION
*----------------------------------------------------------------------*
* Локальный класс для ALV (Определение)
*----------------------------------------------------------------------*
CLASS lcl_alv_handler DEFINITION.
  PUBLIC SECTION.
*  Изменение данных
    METHODS: handle_data_changed
                FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed.

*    Строка кнопок
    METHODS: handle_toolbar
                FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object e_interactive.

*    Обработчик нажатий пользовательских кнопок
    METHODS: handle_user_command
                FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

*    Шапка таблицы
    METHODS: handle_top_of_page
                FOR EVENT top_of_page OF cl_gui_alv_grid
      IMPORTING e_dyndoc_id.

*    Печатная шапка таблицы
    METHODS: handle_print_top_of_page
                FOR EVENT print_top_of_page OF cl_gui_alv_grid
      IMPORTING table_index.
ENDCLASS.                    "lcl_alv_handler DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_alv_handler IMPLEMENTATION
*----------------------------------------------------------------------*
* Локальный класс для ALV (Реализация)
*----------------------------------------------------------------------*
CLASS lcl_alv_handler IMPLEMENTATION.
  METHOD handle_data_changed.
  ENDMETHOD.                    "handle_data_changed

  METHOD handle_toolbar.
  ENDMETHOD.                    "handle_toolbar

  METHOD handle_user_command.
  ENDMETHOD.                    "handle_user_command

  METHOD handle_top_of_page.
  ENDMETHOD.                    "top_of_page

  METHOD handle_print_top_of_page.
  ENDMETHOD.                    "handle_print_top_of_page

ENDCLASS.                    "lcl_alv_handler IMPLEMENTATION

DATA: go_alv_handler TYPE REF TO lcl_alv_handler. " Обработчик для ALV

START-OF-SELECTION.

  CLEAR: gt_alv, gt_alv[].

*  Выбираем данные
  SELECT *
    FROM sflight
    INTO CORRESPONDING FIELDS OF TABLE gt_alv
    UP TO 20 ROWS
    .

END-OF-SELECTION.

DATA tab like gt_alv.
DATA ls_tab LIKE LINE OF tab.

  LOOP AT gt_alv ASSIGNING FIELD-SYMBOL(<ls_alv>).
    DATA ls_cellcolor TYPE lvc_s_scol.
    CLEAR <ls_alv>-cellcolor.
      ls_cellcolor-fname =  'd_wrbtr'.
      ls_cellcolor-color-col = '6' .
      ls_cellcolor-color-inv = '0' .
      ls_cellcolor-color-int = '0' .
    IF <ls_alv>-price > 1000.
*      <ls_alv>-cellcolor = ls_cellcolor.
      APPEND ls_cellcolor TO <ls_alv>-cellcolor.
    ENDIF.
    APPEND <ls_alv> TO tab.

  ENDLOOP.
*  modify gt_alv FROM tab.

*  Вывод данных
  PERFORM out.
*&---------------------------------------------------------------------*
*&      Form  OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM out .
*  Вызов экрана вывода
  CALL SCREEN 100.
ENDFORM.                    " OUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
*  Устанавливаем статус
  SET PF-STATUS 'STATUS100'.

*  Создание и обработка ALV
  PERFORM pbo.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
*  Обработка команд статуса
  CASE sy-ucomm.
    WHEN 'BACK'. " Зеленая назад
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  PBO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pbo .
*  Разделение экрана
  PERFORM split_screen.

*  Вывод ALV
  PERFORM sho_alv.
ENDFORM.                    " PBO
*&---------------------------------------------------------------------*
*&      Form  SPLIT_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM split_screen .
  CLEAR: go_docking, go_splitter, go_container_1, go_container_2.

*  Создаем общий контейнер
  CREATE OBJECT go_docking
    EXPORTING
      parent    = cl_gui_custom_container=>screen0 " Стандартный экран
      repid     = sy-repid
      dynnr     = sy-dynnr
      extension = 10000 " Это ширина. При значении в 10000 становится
      " вытянутой на весь экран
*     ratio     = '95' " Это ширина в процентах. Неудобно то, что его
    .                  " размер должен быть от 5 до 95  включительно

*  Создаем разделитель с 2 строками и 1 столбцом
*  По сути горизонтально делим контейнер на верхнюю и нижнюю части
  CREATE OBJECT go_splitter
    EXPORTING
      parent  = go_docking
      rows    = 2
      columns = 1.

*  Возвращаем верхний контейнер
  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_container_1.

*  Возвращаем нижний контейнер
  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_container_2.

*  Выставляем высоту верхнего контейнера в строках
  CALL METHOD go_splitter->set_row_height
    EXPORTING
      id     = 1
      height = 15.

*  Заполняем заголовок
  PERFORM header.
ENDFORM.                    " SPLIT_SCREEN
*&---------------------------------------------------------------------*
*&      Form  SHO_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sho_alv .
  IF go_alv IS INITIAL . " Если ALV еще не создано

*    Создаем ALV для нижнего контейнера
    CREATE OBJECT go_alv
      EXPORTING
        i_parent          = go_container_2
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    DATA: lt_fcat TYPE lvc_t_fcat.
    FIELD-SYMBOLS: <fs_fcat> TYPE lvc_s_fcat.


*    Создаем каталог полей
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = 'SFLIGHT'
      CHANGING
        ct_fieldcat            = lt_fcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

*    Вариант вывода будет стандартный для программы и имени пользователя
    DATA: ls_variant TYPE disvariant.
    ls_variant-report = sy-repid.
    ls_variant-username = sy-uname.

*    Создаем управляющий элемент для ALV
    CREATE OBJECT go_alv_handler.

*    Устанавливаем обработчики для событий ALV
    SET HANDLER go_alv_handler->handle_data_changed " Изменение данных
                go_alv_handler->handle_user_command " Обработчик нажатия
                                                    " пользовательских кнопок
                go_alv_handler->handle_toolbar " Строка кнопок ALV
                go_alv_handler->handle_top_of_page " Шапка ALV
                go_alv_handler->handle_print_top_of_page " Печатная шапка ALV
                FOR go_alv.

    DATA: lt_exclude TYPE ui_functions.
    DATA: ls_exclude TYPE ui_func.

*    убираем ненужные кнопки из меню
    ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_help.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_info.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
    APPEND ls_exclude TO lt_exclude.
    ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
    APPEND ls_exclude TO lt_exclude.

*    Настройки вывода
    DATA ls_layo TYPE lvc_s_layo.
    ls_layo-sel_mode = 'A'.

*    Вывод ALV
    CALL METHOD go_alv->set_table_for_first_display
      EXPORTING
        i_buffer_active               = 'X'
        i_bypassing_buffer            = 'X'
        i_structure_name              = 'SFLIGHT'
        is_variant                    = ls_variant
        i_save                        = 'A'
        is_layout                     = ls_layo
        it_toolbar_excluding          = lt_exclude[]
      CHANGING
        it_outtab                     = gt_alv[]
        it_fieldcatalog               = lt_fcat[]
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ELSE. " Если ALV уже создано
*    Обновим отображение
    go_alv->refresh_table_display( ).
  ENDIF.
ENDFORM.                    " SHO_ALV
*&---------------------------------------------------------------------*
*&      Form  HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header .
  DATA: l_document TYPE REF TO cl_dd_document,
        l_doctable TYPE REF TO cl_dd_table_element,
        l_column1  TYPE REF TO cl_dd_area,
        l_column2  TYPE REF TO cl_dd_area.

  DATA : dl_text(255) TYPE c. " Переменная для текста
  MOVE: 'SFLIGHT table' TO dl_text.

*  Создаем документ шапки
  CREATE OBJECT l_document.

*  Добавляем текст со стилем заголовка
  CALL METHOD l_document->add_text
    EXPORTING
      text      = dl_text
      sap_style = cl_dd_area=>heading.

*  Добавляем таблицу на 5 колонок
  CALL METHOD l_document->add_table
    EXPORTING
      no_of_columns               = 1
      cell_background_transparent = 'X'
      border                      = '0'
    IMPORTING
      table                       = l_doctable.

*  Добавляем колонку к таблице
  CALL METHOD l_doctable->add_column
    IMPORTING
      column = l_column1.

*  Заполняем дополнительные тексты
  PERFORM titles CHANGING l_column1.

*  Создаем контроллер HTML, если он еще не создан
*  Это нужно ля того, что бы динамически обновлялся заголовок, если он
*  меняется во время работы программы. Если этот контроллер не объявлять,
*  тогда заголовок будет статичным и всегда показывать то, что было в
*  нем при первом заполнении
  IF go_html_cntrl IS INITIAL.
    CREATE OBJECT go_html_cntrl
      EXPORTING
        parent = go_container_1.
  ENDIF.

*  Объединяем все заполненное в один документ
  CALL METHOD l_document->merge_document.

*  Присваиваем HTML контроллер
  l_document->html_control = go_html_cntrl.

*  Выводим HTML в верхний контейнер
  CALL METHOD l_document->display_document
    EXPORTING
      parent             = go_container_1
      reuse_control      = 'X'
      reuse_registration = 'X'.
ENDFORM.                    " HEADER
*&---------------------------------------------------------------------*
*&      Form  TITLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_COLUMN1  text
*----------------------------------------------------------------------*
FORM titles  CHANGING dg_dyndoc_id TYPE REF TO cl_dd_area.
  DATA : dl_text(255) TYPE c.  "Text
  MOVE: 'Other titles' TO dl_text.

*  Добавляем текст
  CALL METHOD dg_dyndoc_id->add_text
    EXPORTING
      text         = dl_text
      sap_fontsize = cl_dd_area=>large.

*  Вставляем пустую линию
  CALL METHOD dg_dyndoc_id->new_line.

  CLEAR : dl_text.
  dl_text = 'Date :'.

*  Добавляем пропуск
  CALL METHOD dg_dyndoc_id->add_gap.

*  Добавляем текст
  CALL METHOD dg_dyndoc_id->add_text
    EXPORTING
      text = dl_text.

  CLEAR dl_text.
  WRITE sy-datum TO dl_text.

*  Добавляем текст
  CALL METHOD dg_dyndoc_id->add_text
    EXPORTING
      text = dl_text.

*  Вставляем пустую строку
  CALL METHOD dg_dyndoc_id->new_line.

  CLEAR : dl_text.
  dl_text = 'Time :'.

*  Добавляем пропуск
  CALL METHOD dg_dyndoc_id->add_gap.

*  Добавляем текст
  CALL METHOD dg_dyndoc_id->add_text
    EXPORTING
      text = dl_text.

  CLEAR dl_text.
  WRITE sy-uzeit TO dl_text.

*  Добавляем текст
  CALL METHOD dg_dyndoc_id->add_text
    EXPORTING
      text = dl_text.

*  Вставляем пустую строку
  CALL METHOD dg_dyndoc_id->new_line.

  dl_text = 'User :'.

*  Добавляем пропуск
  CALL METHOD dg_dyndoc_id->add_gap.

*  Добавляем текст
  CALL METHOD dg_dyndoc_id->add_text
    EXPORTING
      text = dl_text.

  CLEAR dl_text.
  dl_text = sy-uname.

*  Добавляем текст
  CALL METHOD dg_dyndoc_id->add_text
    EXPORTING
      text = dl_text.
ENDFORM.                    " TITLES
