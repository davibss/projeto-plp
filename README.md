# Projeto PLP - Quiz de Cálculo I e II

## Haskell

### Funcionalidades
* Cadastrar, alterar e logar usuário
* Cadastrar, alterar, listar e deletar quizzes
* Cadastrar, alterar, listar e deletar questões
* Cadastrar, alterar, listar e deletar respostas
* Resolver quiz
    * Listar quizzes por tópico
    * Abrir questão no navegador para renderizar qualquer LaTeX
    * Calcular pontuação final
    * Avaliar quiz
* Ver quizzes respondidos
    * Ver pontuação obtida, data da realização e respostas marcadas
* Mostrar pontuação total do usuário no menu principal
* Criar um quiz baseado nas questões respondidas de um tópico da escolha do usuário

### Execução em Haskell(Cabal)

Para executar o comando é necessário ter o cabal instalado na sua máquina, caso já tenha instalado o [haskell-platform](https://www.haskell.org/platform/) não é necessário instalar o cabal manualmente.
Entre no diretório **projeto-haskell** e execute o comando 'cabal run'

#### Cabal 3.0+
```sh
cd projeto-haskell
cabal update
cabal run
```
#### Cabal 2.4
```sh
cd projeto-haskell
cabal new-update
cabal new-run
```
Para saber qual versão do cabal está instalada no seu sistema:
```sh
cabal --version
```

### Database (Sqlite3)

Todas as queries para criação das tabelas estão na pasta **queries**
**Toda** alteração do tipo _DDL_ no banco de dados deve ser adicionada via `ALTER TABLE`