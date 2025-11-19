# Formatic - App de Estudos Inteligente

Formatic é um aplicativo móvel desenvolvido em Flutter para ajudar estudantes a organizarem seus estudos de forma eficiente, unindo flashcards, técnica Pomodoro, gerenciamento de tarefas e um chat com IA para tirar dúvidas e otimizar o aprendizado.

## Funcionalidades

### Flashcards

- Criar, editar e revisar flashcards  
- Organização por matérias e disciplinas  
- Revisão espaçada inteligente  

### Gerenciamento de Tarefas

- Criação e priorização de tarefas  
- Acompanhamento do progresso  
- Integração com o dashboard  

### Chat com IA

- Assistente virtual integrada para estudos  
- Respostas contextuais sobre conteúdo acadêmico  
- Histórico de interações armazenado  
- Apoio para revisão de flashcards e resumos automáticos

## Tecnologias Utilizadas

### Frontend

- Flutter  
- Dart  
- Material Design 3  

### Backend & Banco de Dados

- Supabase (BaaS)  
- PostgreSQL  
- Row Level Security (RLS)  

### Autenticação

- Supabase Auth  
- JWT Tokens  

### Configuração e Execução

### Pré-requisitos

- Flutter SDK 3.0+  
- Dart 2.17+  
- Conta no Supabase  

### Passos para Configuração

    git clone https://github.com/FRANCIELE-SANTOS-SILVA/formatic.git
    cd formatic

### Instale as dependências

    flutter pub get

### Configure o ambiente

    cp .env.example .env

### Crie um arquivo .env com suas credenciais do Supabase e a chave da API

    SUPABASE_URL=sua_url_do_supabase
    SUPABASE_ANON_KEY=sua_chave_anonima
    DEEPSEEK_API_KEY=sua_chave_da_api

### Executar o Projeto

    flutter run

## Formatic - Transformando a maneira como você estuda!
