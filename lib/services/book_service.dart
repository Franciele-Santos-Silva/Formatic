import '../models/book.dart';

class BookService {
  // Lista de livros de exemplo (depois pode ser substituída por dados do Supabase)
  static final List<Book> _sampleBooks = [
    Book(
      id: '1',
      title: 'Cálculo',
      author: 'Arquivo local',
      description: 'Livro/PDF de cálculo adicionado em assets/pdfs.',
      pdfPath: 'assets/pdfs/calculo.pdf',
      coverImageUrl: 'https://picsum.photos/seed/calc_user/200/300',
      tags: [BookTags.matematica, BookTags.cienciasExatas, BookTags.livroTexto, BookTags.introducao],
      addedDate: DateTime.now().subtract(const Duration(days: 30)),
      pageCount: 0,
    ),
    
    Book(
      id: '3',
      title: 'Física I - Mecânica',
      author: 'Halliday & Resnick',
      description: 'Fundamentos de mecânica clássica',
      pdfPath: 'assets/pdfs/fisica1.pdf',
      coverImageUrl: 'https://picsum.photos/seed/fis1/200/300',
      tags: [BookTags.fisica, BookTags.cienciasExatas, BookTags.livroTexto, BookTags.introducao],
      addedDate: DateTime.now().subtract(const Duration(days: 20)),
      pageCount: 432,
    ),
    Book(
      id: '4',
      title: 'Química Orgânica',
      author: 'John McMurry',
      description: 'Química orgânica fundamental',
      pdfPath: 'assets/pdfs/quimica_organica.pdf',
      coverImageUrl: 'https://picsum.photos/seed/quim1/200/300',
      tags: [BookTags.quimica, BookTags.cienciasExatas, BookTags.livroTexto, BookTags.intermediario],
      addedDate: DateTime.now().subtract(const Duration(days: 18)),
      pageCount: 624,
    ),
    Book(
      id: '5',
      title: 'Biologia Celular',
      author: 'Alberts et al.',
      description: 'Fundamentos da biologia celular e molecular',
      pdfPath: 'assets/pdfs/biologia_celular.pdf',
      coverImageUrl: 'https://picsum.photos/seed/bio1/200/300',
      tags: [BookTags.biologia, BookTags.cienciasBiologicas, BookTags.livroTexto, BookTags.avancado],
      addedDate: DateTime.now().subtract(const Duration(days: 15)),
      pageCount: 800,
    ),
    Book(
      id: '6',
      title: 'História do Brasil',
      author: 'Boris Fausto',
      description: 'História concisa do Brasil',
      pdfPath: 'assets/pdfs/historia_brasil.pdf',
      coverImageUrl: 'https://picsum.photos/seed/hist1/200/300',
      tags: [BookTags.historia, BookTags.cienciasHumanas, BookTags.livroTexto, BookTags.intermediario],
      addedDate: DateTime.now().subtract(const Duration(days: 12)),
      pageCount: 368,
    ),
    Book(
      id: '7',
      title: 'Introdução à Filosofia',
      author: 'Marilena Chauí',
      description: 'Convite à filosofia',
      pdfPath: 'assets/pdfs/filosofia_intro.pdf',
      coverImageUrl: 'https://picsum.photos/seed/filo1/200/300',
      tags: [BookTags.filosofia, BookTags.cienciasHumanas, BookTags.livroTexto, BookTags.introducao],
      addedDate: DateTime.now().subtract(const Duration(days: 10)),
      pageCount: 424,
    ),
    Book(
      id: '8',
      title: 'Sociologia Geral',
      author: 'Anthony Giddens',
      description: 'Fundamentos da sociologia moderna',
      pdfPath: 'assets/pdfs/sociologia.pdf',
      coverImageUrl: 'https://picsum.photos/seed/soc1/200/300',
      tags: [BookTags.sociologia, BookTags.cienciasHumanas, BookTags.livroTexto, BookTags.intermediario],
      addedDate: DateTime.now().subtract(const Duration(days: 8)),
      pageCount: 512,
    ),
    Book(
      id: '9',
      title: 'Psicologia do Desenvolvimento',
      author: 'Jean Piaget',
      description: 'Teoria do desenvolvimento cognitivo',
      pdfPath: 'assets/pdfs/psicologia_dev.pdf',
      coverImageUrl: 'https://picsum.photos/seed/psi1/200/300',
      tags: [BookTags.psicologia, BookTags.cienciasHumanas, BookTags.teoria, BookTags.avancado],
      addedDate: DateTime.now().subtract(const Duration(days: 6)),
      pageCount: 288,
    ),
    Book(
      id: '10',
      title: 'Algoritmos e Estruturas de Dados',
      author: 'Thomas Cormen',
      description: 'Introduction to Algorithms',
      pdfPath: 'assets/pdfs/algoritmos.pdf',
      coverImageUrl: 'https://picsum.photos/seed/algo1/200/300',
      tags: [BookTags.computacao, BookTags.cienciasExatas, BookTags.livroTexto, BookTags.avancado],
      addedDate: DateTime.now().subtract(const Duration(days: 5)),
      pageCount: 1312,
    ),
    Book(
      id: '11',
      title: 'Exercícios de Cálculo',
      author: 'Diversos Autores',
      description: 'Lista completa de exercícios resolvidos',
      pdfPath: 'assets/pdfs/exercicios_calculo.pdf',
      coverImageUrl: 'https://picsum.photos/seed/ex1/200/300',
      tags: [BookTags.matematica, BookTags.cienciasExatas, BookTags.livroExercicios, BookTags.intermediario],
      addedDate: DateTime.now().subtract(const Duration(days: 3)),
      pageCount: 184,
    ),
    Book(
      id: '12',
      title: 'Direito Constitucional',
      author: 'Pedro Lenza',
      description: 'Direito constitucional esquematizado',
      pdfPath: 'assets/pdfs/dir_constitucional.pdf',
      coverImageUrl: 'https://picsum.photos/seed/dir1/200/300',
      tags: [BookTags.direito, BookTags.cienciasHumanas, BookTags.livroTexto, BookTags.intermediario],
      addedDate: DateTime.now().subtract(const Duration(days: 2)),
      pageCount: 896,
    ),
    Book(
      id: '13',
      title: 'Administração Geral',
      author: 'Chiavenato',
      description: 'Teoria geral da administração',
      pdfPath: 'assets/pdfs/administracao.pdf',
      coverImageUrl: 'https://picsum.photos/seed/adm1/200/300',
      tags: [BookTags.administracao, BookTags.cienciasHumanas, BookTags.livroTexto, BookTags.introducao],
      addedDate: DateTime.now().subtract(const Duration(days: 1)),
      pageCount: 624,
    ),
    Book(
      id: '14',
      title: 'Engenharia de Software',
      author: 'Ian Sommerville',
      description: 'Fundamentos de engenharia de software',
      pdfPath: 'assets/pdfs/eng_software.pdf',
      coverImageUrl: 'https://picsum.photos/seed/eng1/200/300',
      tags: [BookTags.engenharias, BookTags.computacao, BookTags.livroTexto, BookTags.intermediario],
      addedDate: DateTime.now(),
      pageCount: 568,
    ),
    Book(
      id: '15',
      title: 'Resumo de Física Moderna',
      author: 'Diversos',
      description: 'Resumo completo de física quântica',
      pdfPath: 'assets/pdfs/resumo_fisica_moderna.pdf',
      coverImageUrl: 'https://picsum.photos/seed/res1/200/300',
      tags: [BookTags.fisica, BookTags.cienciasExatas, BookTags.resumo, BookTags.avancado],
      addedDate: DateTime.now(),
      pageCount: 96,
    ),
  ];

  // Buscar todos os livros
  Future<List<Book>> getAllBooks() async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    return _sampleBooks;
  }

  // Buscar livros por texto (título, autor, descrição)
  Future<List<Book>> searchBooks(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (query.isEmpty) {
      return _sampleBooks;
    }

    final lowerQuery = query.toLowerCase();
    return _sampleBooks.where((book) {
      return book.title.toLowerCase().contains(lowerQuery) ||
             book.author.toLowerCase().contains(lowerQuery) ||
             book.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Filtrar livros por tags
  Future<List<Book>> filterByTags(List<String> selectedTags) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (selectedTags.isEmpty) {
      return _sampleBooks;
    }

    return _sampleBooks.where((book) {
      // Verifica se o livro tem pelo menos uma das tags selecionadas
      return book.tags.any((tag) => selectedTags.contains(tag));
    }).toList();
  }

  // Buscar e filtrar combinados
  Future<List<Book>> searchAndFilter(String query, List<String> selectedTags) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    List<Book> results = _sampleBooks;

    // Aplicar busca por texto
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results.where((book) {
        return book.title.toLowerCase().contains(lowerQuery) ||
               book.author.toLowerCase().contains(lowerQuery) ||
               book.description.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // Aplicar filtro de tags
    if (selectedTags.isNotEmpty) {
      results = results.where((book) {
        return book.tags.any((tag) => selectedTags.contains(tag));
      }).toList();
    }

    return results;
  }

  // Buscar livro por ID
  Future<Book?> getBookById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    try {
      return _sampleBooks.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obter livros recentes
  Future<List<Book>> getRecentBooks({int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final sortedBooks = List<Book>.from(_sampleBooks);
    sortedBooks.sort((a, b) => b.addedDate.compareTo(a.addedDate));
    
    return sortedBooks.take(limit).toList();
  }
}
