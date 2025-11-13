class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String pdfPath;
  final String coverImageUrl;
  final List<String> tags;
  final DateTime addedDate;
  final int pageCount;
  final String language;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.pdfPath,
    required this.coverImageUrl,
    required this.tags,
    required this.addedDate,
    this.pageCount = 0,
    this.language = 'pt-BR',
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      pdfPath: json['pdf_path'] ?? '',
      coverImageUrl: json['cover_image_url'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      addedDate: json['added_date'] != null
          ? DateTime.parse(json['added_date'])
          : DateTime.now(),
      pageCount: json['page_count'] ?? 0,
      language: json['language'] ?? 'pt-BR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'pdf_path': pdfPath,
      'cover_image_url': coverImageUrl,
      'tags': tags,
      'added_date': addedDate.toIso8601String(),
      'page_count': pageCount,
      'language': language,
    };
  }
}

class BookTags {
  static const String cienciasExatas = 'ciencias-exatas';
  static const String cienciasHumanas = 'ciencias-humanas';
  static const String cienciasBiologicas = 'ciencias-biologicas';
  static const String engenharias = 'engenharias';
  static const String linguasELetras = 'linguas-e-letras';
  static const String direito = 'direito';
  static const String administracao = 'administracao';

  static const String computacao = 'computacao';
  static const String matematica = 'matematica';
  static const String fisica = 'fisica';
  static const String quimica = 'quimica';
  static const String biologia = 'biologia';
  static const String historia = 'historia';
  static const String filosofia = 'filosofia';
  static const String medicina = 'medicina';
  static const String psicologia = 'psicologia';

  /// Tipo de conteúdo
  static const String livroTexto = 'livro-texto';
  static const String livroExercicios = 'livro-de-exercicios';
  static const String teoria = 'teoria';
  static const String resumo = 'resumo';

  static const String introducao = 'introducao';
  static const String intermediario = 'intermediario';
  static const String avancado = 'avancado';

  static const Map<String, String> tagLabels = {
    cienciasExatas: 'Ciências Exatas',
    cienciasHumanas: 'Ciências Humanas',
    cienciasBiologicas: 'Ciências Biológicas',
    engenharias: 'Engenharias',
    linguasELetras: 'Línguas e Letras',
    direito: 'Direito',
    administracao: 'Administração',

    computacao: 'Computação',
    matematica: 'Matemática',
    fisica: 'Física',
    quimica: 'Química',
    biologia: 'Biologia',
    historia: 'História',
    filosofia: 'Filosofia',
    medicina: 'Medicina',
    psicologia: 'Psicologia',

    livroTexto: 'Livro-texto',
    livroExercicios: 'Exercícios',
    teoria: 'Teoria',
    resumo: 'Resumo',

    introducao: 'Introdução',
    intermediario: 'Intermediário',
    avancado: 'Avançado',
  };

  static const List<String> allTags = [
    cienciasExatas,
    cienciasHumanas,
    cienciasBiologicas,
    engenharias,
    linguasELetras,
    direito,
    administracao,

    computacao,
    matematica,
    fisica,
    quimica,
    biologia,
    historia,
    filosofia,
    medicina,
    psicologia,

    livroTexto,
    livroExercicios,
    teoria,
    resumo,

    introducao,
    intermediario,
    avancado,
  ];
}
