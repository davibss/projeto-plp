# Instalação do Projeto em Prolog

## Versão do Prolog
Utilizaremos a versão SWI-PROLOG,
[Link](https://www.swi-prolog.org/download/stable) para instalação.

## Bibliotecas
A única biblioteca que será necessária para o nosso projeto será a [proSQLite](https://www.swi-prolog.org/pack/file_details/prosqlite/doc/prosqlite.html).

### Instalação do proSQLite
```sh
swipl
?- pack_install( prosqlite ).
```
Este comando irá instalar o prosqlite globalmente.

### Executando o projeto
```sh
cd projeto-prolog
swipl main.pl
```

```prolog
?- main.
```