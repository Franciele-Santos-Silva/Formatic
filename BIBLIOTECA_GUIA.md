# 📚 Biblioteca Digital - Guia de Uso

## ✨ Funcionalidades Implementadas

### 1. **Página da Biblioteca** (`library_page.dart`)
- ✅ Grade responsiva de livros (2-5 colunas dependendo da largura da tela)
- ✅ Barra de busca em tempo real (pesquisa por título, autor e descrição)
- ✅ Sistema de filtros por tags com 24 categorias diferentes
- ✅ Contador de resultados
- ✅ Design adaptado para modo claro/escuro

### 2. **Visualizador de PDF** (`pdf_viewer_page.dart`)
- ✅ Suporte para PDFs locais (assets) e URLs externas
- ✅ Navegação entre páginas (anterior/próxima)
- ✅ Indicador de página atual
- ✅ Busca rápida por número de página
- ✅ Modal com informações completas do livro
- ✅ Controles intuitivos na parte inferior

### 3. **Sistema de Tags**
Categorias disponíveis para filtrar:

**Áreas do conhecimento:**
- Ciências Exatas
- Ciências Humanas
- Ciências Biológicas
- Engenharias
- Línguas e Letras
- Direito
- Administração

**Disciplinas específicas:**
- Computação
- Matemática
- Física
- Química
- Biologia
- História
- Filosofia
- Sociologia
- Psicologia

**Tipo de conteúdo:**
- Livro-texto
- Livro de exercícios
- Teoria
- Resumo

**Nível:**
- Introdução
- Intermediário
- Avançado

## 🚀 Como Usar

### Navegação na Biblioteca
1. Acesse a aba "Bibliotecas" no menu inferior
2. Use a barra de busca para pesquisar por título, autor ou palavra-chave
3. Clique no ícone de filtro para abrir as tags
4. Selecione uma ou mais tags para filtrar
5. Clique em qualquer livro para abrir o visualizador de PDF

### Lendo um Livro
1. Use os botões de navegação na parte inferior (← →)
2. Clique no indicador de página para ir diretamente para uma página específica
3. Clique no ícone ℹ️ para ver informações completas do livro
4. Use o botão voltar para retornar à biblioteca

## 📝 Como Adicionar PDFs

### Opção 1: PDFs Locais (Assets)

1. **Baixe o arquivo PDF** que deseja adicionar
2. **Coloque na pasta** `assets/pdfs/`
3. **Renomeie** com um nome descritivo sem espaços (ex: `calculo_volume1.pdf`)
4. **Edite** o arquivo `lib/services/book_service.dart`
5. **Adicione** um novo livro na lista `_sampleBooks`:

```dart
Book(
  id: '16', // Próximo ID disponível
  title: 'Nome do Livro',
  author: 'Nome do Autor',
  description: 'Descrição breve do conteúdo',
  pdfPath: 'assets/pdfs/seu_arquivo.pdf', // Caminho do arquivo
  coverImageUrl: 'https://picsum.photos/seed/seu_id/200/300', // Imagem de capa
  tags: [
    BookTags.matematica, // Escolha as tags apropriadas
    BookTags.cienciasExatas,
    BookTags.livroTexto,
    BookTags.intermediario
  ],
  addedDate: DateTime.now(),
  pageCount: 350, // Número de páginas
),
```

6. **Execute** `flutter pub get` e reinicie o app

### Opção 2: PDFs Online (URLs)

Se o PDF está hospedado online, use a URL diretamente:

```dart
Book(
  id: '17',
  title: 'Livro Online',
  author: 'Autor',
  description: 'Descrição',
  pdfPath: 'https://example.com/livro.pdf', // URL completa
  coverImageUrl: 'https://picsum.photos/seed/online1/200/300',
  tags: [BookTags.computacao],
  addedDate: DateTime.now(),
  pageCount: 200,
),
```

**Vantagens da URL:**
- Não ocupa espaço no app
- Pode ser atualizado sem rebuildar o app
- Ideal para bibliotecas online

**Desvantagens:**
- Requer conexão com internet
- Depende da disponibilidade do servidor

## 🎨 Personalização

### Alterar Tags
Edite `lib/models/book.dart` na classe `BookTags` para:
- Adicionar novas tags
- Remover tags existentes
- Alterar os labels das tags

### Modificar o Layout da Grade
Em `library_page.dart`, no método `_getCrossAxisCount`, ajuste os valores:

```dart
int _getCrossAxisCount(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width > 1200) return 5; // Telas muito grandes
  if (width > 900) return 4;  // Telas grandes
  if (width > 600) return 3;  // Tablets
  return 2;                    // Mobile
}
```

## 📦 Dependências Adicionadas

```yaml
syncfusion_flutter_pdfviewer: ^28.1.33  # Visualizador de PDF
path_provider: ^2.1.1                    # Acesso a diretórios
url_launcher: ^6.2.1                     # Abrir URLs
```

## 📚 Livros de Exemplo Incluídos

15 livros de exemplo já estão configurados em várias áreas:
1. Introdução à Programação
2. Cálculo Volume I
3. Física I - Mecânica
4. Química Orgânica
5. Biologia Celular
6. História do Brasil
7. Introdução à Filosofia
8. Sociologia Geral
9. Psicologia do Desenvolvimento
10. Algoritmos e Estruturas de Dados
11. Exercícios de Cálculo
12. Direito Constitucional
13. Administração Geral
14. Engenharia de Software
15. Resumo de Física Moderna

## ⚠️ Notas Importantes

1. **Direitos Autorais**: Use apenas PDFs de domínio público ou que você tenha direitos de distribuição
2. **Tamanho**: PDFs muito grandes (>50MB) podem causar lentidão
3. **Formato**: Apenas arquivos PDF válidos são suportados
4. **Imagens**: As URLs de capa usam `picsum.photos` como placeholder - substitua por imagens reais se desejar

## 🔗 Fontes Recomendadas para PDFs Gratuitos

- **Project Gutenberg**: https://www.gutenberg.org/
- **Open Library**: https://openlibrary.org/
- **MIT OpenCourseWare**: https://ocw.mit.edu/
- **Domínio Público (Brasil)**: http://www.dominiopublico.gov.br/
- **arXiv** (artigos científicos): https://arxiv.org/

## 🎯 Próximos Passos Sugeridos

1. **Integração com Supabase**: Armazenar a lista de livros no banco de dados
2. **Upload de PDFs**: Permitir que usuários façam upload de seus próprios PDFs
3. **Marcadores**: Sistema de favoritos e leitura
4. **Notas**: Adicionar anotações nas páginas
5. **Progresso de leitura**: Salvar a última página lida
6. **Download offline**: Baixar PDFs para leitura sem internet

Tudo pronto! 🎉
