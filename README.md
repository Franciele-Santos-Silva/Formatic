# Formatic - App de Estudos Inteligente

Formatic é um aplicativo móvel desenvolvido em Flutter para ajudar estudantes a organizarem seus estudos de forma eficiente, unindo flashcards, técnica Pomodoro e gerenciamento de tarefas em uma única plataforma.

## Funcionalidades

### Flashcards

- Criar, editar e revisar flashcards  
- Organização por matérias e disciplinas  
- Revisão espaçada inteligente  

### Timer Pomodoro

- Sessões de foco (25 min) e descanso (5 min)  
- Registro automático do tempo estudado  
- Métricas de produtividade  

### Gerenciamento de Tarefas

- Criação e priorização de tarefas  
- Acompanhamento do progresso  
- Integração com o dashboard  

### Dashboard de Métricas

- Tempo total de estudo  
- Sessões completadas  
- Progresso diário e semanal  

### Tecnologias Utilizadas

## Frontend

- Flutter  
- Dart  
- Material Design 3  

## Backend & Banco de Dados

- Supabase (BaaS)  
- PostgreSQL  
- Row Level Security (RLS)  

## Autenticação

- Supabase Auth  
- JWT Tokens  

## Configuração e Execução

### Pré-requisitos

- Flutter SDK 3.0+  
- Dart 2.17+  
- Conta no Supabase  

## Passos para Configuração

    git clone https://github.com/FRANCIELE-SANTOS-SILVA/formatic.git
    cd formatic

## Instale as dependências

    flutter pub get

## Configure o ambiente

    cp .env.example .env
    