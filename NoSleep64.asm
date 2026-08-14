;format PE64 CONSOLE 5.0 ; Формат для 64-битных систем (для отладки)
format PE64 GUI 5.0 ; Меняем на GUI, чтобы программа запускалась без окон
entry start

include 'win64a.inc'

section '.code' code readable executable

start:
;    ; Константы для SetThreadExecutionState
;    ES_CONTINUOUS       = 80000000h
;    ES_SYSTEM_REQUIRED  = 00000001h
;    ES_DISPLAY_REQUIRED = 00000002h
;
;    ; Итоговая маска флагов: непрерывно держать включенными систему и дисплей
;    EXEC_STATE_FLAGS    = ES_CONTINUOUS + ES_SYSTEM_REQUIRED + ES_DISPLAY_REQUIRED
    ; Передаем флаги в RCX (ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED)
    mov     rcx, 80000003h  ; Собранный флаг (ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED)
    sub     rsp, 32         ; Резервируем теневой стек (Shadow space)
    call    [SetThreadExecutionState]
    add     rsp, 32         ; Восстанавливаем стек
    
    ; Если функция вернула 0 (ошибка), просто тихо завершаем работу
    test    rax, rax
    jz      exit

main_loop:
    ; Бесконечный цикл с засыпанием на 60 секунд (0% нагрузки на CPU)
    mov     rcx, 60000
    sub     rsp, 32
    call    [Sleep]
    add     rsp, 32
    jmp     main_loop

exit:
    ; Если произошла ошибка, получаем её код и выходим
    mov     rcx, 0
    sub     rsp, 32
    call    [ExitProcess]

; Секция импорта функций
section '.idata' import data readable writeable

    library kernel32, 'kernel32.dll'

    import kernel32, \
           SetThreadExecutionState, 'SetThreadExecutionState', \
           Sleep, 'Sleep', \
           ExitProcess, 'ExitProcess'
