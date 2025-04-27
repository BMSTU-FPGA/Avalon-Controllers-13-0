# TODO List

##  1. Обеспечить совместимость с Quartus 13.0

Контроллеры были созданы используя Quartus 23.1. Чтобы обеспечить выполнение студентами лабораторных работ на этих контроллерах, необходимо разрешить проблему несовместимости этих версий Quartus

### Выявленные несовместимости

Quartus 23.1 -> Quartus 13.0

#### TCL скрипты компонентов

Созданные контроллеры имеют разницу в их описании между версиями

##### Решение конфликтов

- **CHANGE** `package require -exact qsys 16.1` -> `package require -exact qsys 13.1` ;
- **REMOVE** `set_module_property REPORT_HIERARCHY false`
- **REMOVE** `set_fileset_property QUARTUS_SYNTH EMABLE_FILE_OVERWRITE_MODE     false`
- **REMOVE** `set_interface_property {имя_интерфейса} CMSIS_SVD_VARIABLES ""`

#### Nios II

В Platfrom Designer Quartus 23.1 и в Quartus 13.0 содержатся раздые версии процессора Nios II

##### Решение конфликтов

!TODO

