# fish-container

Um terminal pronto em container, com fish, starship, bat, eza, zoxide e fzf já configurados. Roda com Docker ou com Podman, sem instalar as ferramentas no sistema do host. Basta o motor de container e uma Nerd Font no terminal.

A configuração é baseada no setup mostrado no vídeo de terminal da Rocketseat, adaptada para Linux e para container.

## O que vem dentro

| Ferramenta | Função |
| --- | --- |
| fish | Shell, com autosugestão e realce de sintaxe por padrão |
| starship | Prompt que mostra versão do Node, Docker e outros conforme o projeto |
| bat | Substitui o `cat`, com realce de sintaxe |
| eza | Substitui o `ls`, com ícones |
| zoxide | Substitui o `cd`, aprendendo as pastas que você visita |
| fzf | Busca difusa: `Ctrl+T` para arquivos, `Ctrl+R` para histórico |
| fd, silversearcher-ag | Busca de arquivos e de conteúdo, usados junto com o fzf |

A imagem é baseada em Debian 13, porque o fzf de lá já traz a integração com o fish (`fzf --fish`).

## Pré-requisitos

Docker ou Podman instalado. No Podman, use o modo rootless (sem root), que é o padrão.

Para os ícones do eza e do starship aparecerem, o terminal do seu host precisa usar uma Nerd Font, por exemplo a JetBrainsMono Nerd Font, baixada em [nerdfonts.com](https://www.nerdfonts.com). O container só envia os caracteres, quem desenha é o terminal que você está usando.

## Instalação

```bash
git clone <url-deste-repositorio> fish-container
cd fish-container
chmod +x run.sh
./run.sh build
```

O `chmod +x` só é necessário se o script veio de um zip ou perdeu a permissão de execução. Sem ele, o shell responde "permissão negada".

O `build` usa o seu UID e GID como dono do usuário dentro do container, para que os arquivos criados na pasta montada pertençam a você no host.

## Uso

Abra o terminal montando o diretório atual em `/work`:

```bash
./run.sh
```

Ou monte outra pasta, por exemplo a dos seus projetos:

```bash
./run.sh ~/projetos
```

A pasta montada em `/work` é a pasta real do host: o que você criar, editar ou apagar lá dentro vale fora do container também. O resto do sistema de arquivos do container é descartado ao sair.

O script usa o Podman se ele existir e cai para o Docker caso contrário. Para escolher um deles:

```bash
ENGINE=podman ./run.sh
ENGINE=docker ./run.sh
```

Dentro do container, alguns exemplos:

```fish
cat package.json        # bat, com realce de sintaxe
ls                      # eza com ícones
l                       # eza em formato longo, com status do git
cd documentacao         # zoxide: entra na pasta pelo trecho do nome, depois de visitá-la uma vez
```

Atalhos do fzf: `Ctrl+T` busca arquivos com preview e `Ctrl+R` busca no histórico de comandos.

### Comandos equivalentes sem o script

Se preferir rodar na mão, estes são os comandos que o `run.sh` executa.

Docker:

```bash
docker build --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) -t fish-container .
docker run --rm -it --security-opt label=disable -e TERM -e COLORTERM=truecolor \
  -v fish-container-data:/home/dev/.local/share -v "$PWD":/work -w /work fish-container
```

Podman:

```bash
podman build --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) -t fish-container .
podman run --rm -it --userns=keep-id --security-opt label=disable -e TERM -e COLORTERM=truecolor \
  -v fish-container-data:/home/dev/.local/share -v "$PWD":/work -w /work fish-container
```

## Persistência

O container é descartado ao sair (`--rm`), mas o volume `fish-container-data` guarda o histórico do fish e o banco do zoxide. Assim o `Ctrl+R` e o `cd` por trecho de nome continuam funcionando entre sessões. Para zerar tudo:

```bash
docker volume rm fish-container-data   # ou: podman volume rm fish-container-data
```

## Personalizar

As configurações ficam em `config/` e são copiadas para a imagem no build. Depois de editar, rode `./run.sh build` de novo.

```text
fish-container/
├── Dockerfile
├── run.sh
├── config/
│   ├── fish/config.fish    aliases, init do starship, zoxide e fzf
│   └── starship.toml       configuração do prompt
└── README.md
```

Para adicionar um pacote, inclua o nome na lista do `apt-get install` no `Dockerfile`.

## Problemas comuns

Ícones quebrados ou quadradinhos: o terminal do host não está com uma Nerd Font selecionada.

Erro de permissão em arquivos da pasta montada: reconstrua a imagem com `./run.sh build` na mesma conta de usuário que vai usá-la, porque o UID é fixado no build.

Em Fedora ou outras distros com SELinux, o script já passa `--security-opt label=disable` para o container conseguir ler a pasta montada sem precisar reetiquetá-la.

Comando `bat` ou `fd` não encontrado: no Debian eles se chamam `batcat` e `fdfind`. A imagem já cria os links `bat` e `fd`, então o problema só aparece se você trocar a imagem base.
